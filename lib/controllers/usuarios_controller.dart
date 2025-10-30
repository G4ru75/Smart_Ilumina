import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_ilumina/models/usuarios_models.dart';
import 'package:smart_ilumina/utils/auth_storage.dart';

import 'package:smart_ilumina/controllers/habitaciones_controller.dart'; // <-- importar

class UsuariosController extends GetxController with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final storage = GetStorage();
  final AuthStorage _authStorage = AuthStorage();

  final String usuariosColeccion = 'usuarios';

  final Rxn<Usuario> usuario = Rxn<Usuario>();
  var isLoading = false.obs;
  var isCheckingSession = false.obs; // Para el splash inicial

  // Para detectar cambios en el email automáticamente
  StreamSubscription<User?>? _authStateSubscription;
  bool _isCheckingEmailChange = false; // Prevenir verificaciones simultáneas
  String?
  _lastProcessedEmail; // Para evitar procesar el mismo email múltiples veces
  DateTime? _lastCheckTimestamp; // Cooldown entre verificaciones
  bool _emailUpdateNotificationShown = false; // Prevenir alertas duplicadas
  Timer? _resumeDebounceTimer; // Debounce para resume events

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _setupAuthStateListener();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _authStateSubscription?.cancel();
    _resumeDebounceTimer?.cancel();
    super.onClose();
  }

  /// Detecta cuando la app regresa del background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // La app volvió a primer plano, verificar verificación de email
      debugPrint('📱 App resumed - verificando verificación de email...');

      // Debounce de 1 segundo para evitar múltiples llamadas
      _resumeDebounceTimer?.cancel();
      _resumeDebounceTimer = Timer(const Duration(seconds: 1), () {
        _checkEmailVerificationAndUpdate();
      });
    }
  }

  /// Configura el listener de cambios de estado de autenticación
  /// Usa idTokenChanges() para reducir eventos innecesarios
  void _setupAuthStateListener() {
    _authStateSubscription = _auth.idTokenChanges().listen((User? user) async {
      if (user != null) {
        // Verificar si el email fue verificado y actualizar
        await _checkEmailVerificationAndUpdate();
      }
    });
  }

  /// Verifica si el email fue verificado y actualiza automáticamente
  /// Maneja la expiración del token y re-login automático si es necesario
  Future<void> _checkEmailVerificationAndUpdate() async {
    // 1. Prevenir múltiples verificaciones simultáneas
    if (_isCheckingEmailChange) {
      debugPrint('⏭️ Ya hay una verificación en progreso, saltando...');
      return;
    }

    // 2. Cooldown de 5 segundos entre verificaciones
    // IMPORTANTE: Si el timestamp es null, significa que fue reseteado intencionalmente
    // (ej: después de login), así que permitimos la verificación inmediatamente
    if (_lastCheckTimestamp != null) {
      final diff = DateTime.now().difference(_lastCheckTimestamp!);
      if (diff.inSeconds > 0 && diff.inSeconds < 5) {
        debugPrint('⏱️ Cooldown activo (${diff.inSeconds}s), esperando...');
        return;
      }
    }

    try {
      _isCheckingEmailChange = true;
      _lastCheckTimestamp = DateTime.now();

      final currentUser = _auth.currentUser;

      // Si no hay usuario autenticado, intentar auto-login
      if (currentUser == null) {
        debugPrint('⚠️ No hay usuario autenticado, intentando auto-login...');
        final authData = _authStorage.readAuthData();
        if (authData != null) {
          await loginUsuario(
            authData['email']!,
            authData['password']!,
            silentMode: true,
          );
        }
        return;
      }

      if (usuario.value == null) return;

      try {
        // Recargar el usuario para obtener el estado más reciente
        debugPrint('🔄 Recargando estado del usuario desde Firebase...');
        await currentUser.reload();
      } on FirebaseAuthException catch (e) {
        // Si el token expiró durante verificación de email, hacer auto-login
        if (e.code == 'user-token-expired' || e.code == 'user-not-found') {
          debugPrint(
            '⚠️ Token expirado detectado durante verificación de email.',
          );

          // CRÍTICO: Leer de AuthStorage que ahora tiene el email NUEVO
          final authData = _authStorage.readAuthData();
          String? email = authData?['email'];
          String? password = authData?['password'];

          debugPrint('📧 Email de AuthStorage para auto-login: $email');

          // Cerrar sesión
          await _auth.signOut();
          debugPrint('🔓 Sesión cerrada.');

          // CRÍTICO: Liberar el flag Y resetear el timestamp ANTES del auto-login
          // para permitir que el login pueda verificar el email sin cooldown
          _isCheckingEmailChange = false;
          _lastCheckTimestamp = null;

          // AUTO-LOGIN automático
          if (email != null && password != null) {
            debugPrint('🔄 Iniciando sesión automáticamente con: $email');
            try {
              // Mostrar mensaje al usuario
              try {
                Get.snackbar(
                  '✅ Email verificado',
                  'Reiniciando sesión automáticamente...',
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (_) {
                debugPrint('⚠️ No se pudo mostrar notificación');
              }

              // Auto-login
              await loginUsuario(email, password, silentMode: false);
              debugPrint('✅ Auto-login completado exitosamente');
              return; // Salir aquí para evitar doble liberación en finally
            } catch (loginError) {
              debugPrint('❌ Error en auto-login: $loginError');
              try {
                Get.snackbar(
                  'Error',
                  'Por favor, inicia sesión manualmente',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              } catch (_) {}
              return; // Salir aquí para evitar doble liberación en finally
            }
          } else {
            debugPrint(
              '⚠️ No hay credenciales guardadas. Usuario debe iniciar sesión manualmente.',
            );
          }

          return;
        }
        rethrow;
      }

      final refreshedUser = _auth.currentUser;
      if (refreshedUser == null || refreshedUser.email == null) return;

      // Verificar si ya procesamos este email
      if (_lastProcessedEmail == refreshedUser.email) {
        return;
      }

      // Obtener el email actual de Firestore para comparar
      final firestoreDoc = await _firestore
          .collection(usuariosColeccion)
          .doc(refreshedUser.uid)
          .get();

      if (!firestoreDoc.exists) return;

      final firestoreData = firestoreDoc.data() as Map<String, dynamic>;
      final firestoreEmail = firestoreData['email'] as String?;

      if (firestoreEmail == null) return;

      // Verificar si el email en Firebase Auth es diferente al de Firestore Y está verificado
      if (refreshedUser.emailVerified &&
          refreshedUser.email != firestoreEmail) {
        final oldEmail = firestoreEmail;
        final newEmail = refreshedUser.email!;

        debugPrint('✅ Email verificado detectado: $oldEmail → $newEmail');

        // Marcar como procesado
        _lastProcessedEmail = newEmail;

        // 1. Actualizar en Firestore
        await _firestore
            .collection(usuariosColeccion)
            .doc(refreshedUser.uid)
            .update({'email': newEmail});
        debugPrint('✅ Email actualizado en Firestore');

        // 2. Actualizar credenciales locales en AuthStorage
        final authData = _authStorage.readAuthData();
        if (authData != null) {
          await _authStorage.saveAuthData(newEmail, authData['password']!);
          debugPrint('✅ Credenciales actualizadas en AuthStorage');
        }

        // 3. Actualizar estado local reactivo (GetX)
        if (usuario.value != null) {
          usuario.value = Usuario(
            nombre: usuario.value!.nombre,
            email: newEmail,
            fechaNacimiento: usuario.value!.fechaNacimiento,
          );
          debugPrint('✅ Estado local actualizado (GetX)');
        }

        // 4. Mostrar notificación única y no invasiva
        if (!_emailUpdateNotificationShown) {
          try {
            Get.snackbar(
              '✅ Email actualizado',
              'Tu correo electrónico ha sido cambiado correctamente a $newEmail',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
              snackPosition: SnackPosition.BOTTOM,
              isDismissible: true,
            );
            _emailUpdateNotificationShown = true;
            debugPrint('✅ Notificación de éxito mostrada');
          } catch (e) {
            debugPrint(
              '⚠️ No se pudo mostrar notificación (contexto no disponible): $e',
            );
          }
        }

        debugPrint('🎉 Sincronización completada exitosamente');
      }
    } catch (e) {
      debugPrint('❌ Error al verificar y actualizar email: $e');
    } finally {
      _isCheckingEmailChange = false;
    }
  }

  Future<bool> autoLogin() async {
    isCheckingSession.value = true;
    try {
      final authData = _authStorage.readAuthData();
      if (authData != null) {
        final result = await loginUsuario(
          authData['email']!,
          authData['password']!,
          silentMode: true, // No mostrar snackbar en auto-login
        );
        isCheckingSession.value = false;
        return result;
      }
      isCheckingSession.value = false;
      return false;
    } catch (e) {
      debugPrint('Error en auto-login: $e');
      isCheckingSession.value = false;
      return false;
    }
  }

  Future<bool> loginUsuario(
    String email,
    String contrasena, {
    bool silentMode = false,
  }) async {
    try {
      isLoading.value = true;

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: contrasena,
      );

      // Guardar credenciales usando AuthStorage
      await _authStorage.saveAuthData(email, contrasena);

      // Cargar datos del usuario desde Firestore
      await cargarDatosUsuario(userCredential.user!.uid);

      // CRÍTICO: Resetear el estado de sincronización para permitir verificación en este nuevo login
      _lastProcessedEmail = null;
      _lastCheckTimestamp = null;

      // CRÍTICO: Verificar si hay diferencia entre Firebase Auth y Firestore después del login
      await _checkEmailVerificationAndUpdate();

      // Cargar habitaciones (si el controlador existe)
      if (Get.isRegistered<HabitacionesController>()) {
        await Get.find<HabitacionesController>().cargarHabitacionesUsuario();
      }

      if (!silentMode) {
        Get.snackbar(
          'Éxito',
          'Inicio de sesión exitoso',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      // Si falla el auto-login, limpiar credenciales guardadas
      if (silentMode) {
        await _authStorage.clearAuthData();
      }
      isLoading.value = false;
      if (!silentMode) {
        Get.snackbar(
          'Error',
          e.message ?? 'Error desconocido',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return false;
    } catch (e, s) {
      debugPrint('Login post-auth error: $e\n$s');
      if (silentMode) {
        await _authStorage.clearAuthData();
      }
      if (!silentMode) {
        Get.snackbar(
          'Error',
          '$e Ocurrió un problema al continuar',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registrarUsuario(
    String nombre,
    DateTime fechaNacimiento,
    String email,
    String contrasena,
  ) async {
    try {
      isLoading.value = true;
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: contrasena,
      );

      final nuevoUsuario = Usuario(
        nombre: nombre,
        fechaNacimiento: fechaNacimiento,
        email: email,
      );

      await _firestore
          .collection(usuariosColeccion)
          .doc(cred.user!.uid)
          .set(nuevoUsuario.toMap());

      if (Get.isRegistered<HabitacionesController>()) {
        await Get.find<HabitacionesController>().cargarHabitacionesUsuario();
      }

      Get.snackbar(
        'Éxito',
        'Usuario registrado exitosamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message ?? 'Error desconocido',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Cierra sesión y limpia todos los datos guardados
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _auth.signOut();
      await _authStorage.clearAuthData();
      usuario.value = null;

      Get.snackbar(
        'Sesión cerrada',
        'Has cerrado sesión exitosamente',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );

      Get.offAllNamed('/login');
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
      Get.snackbar(
        'Error',
        'Ocurrió un error al cerrar sesión',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifica si hay una sesión guardada
  bool hasSession() {
    return _authStorage.hasSession();
  }

  /// Carga los datos del usuario desde Firestore
  Future<void> cargarDatosUsuario(String uid) async {
    try {
      debugPrint('🔍 Cargando datos del usuario con UID: $uid');
      final doc = await _firestore.collection(usuariosColeccion).doc(uid).get();
      if (doc.exists) {
        debugPrint('✅ Documento encontrado: ${doc.data()}');
        usuario.value = Usuario.fromMap(doc.data()!);
        debugPrint(
          '✅ Usuario cargado: ${usuario.value?.nombre} - ${usuario.value?.email}',
        );
      } else {
        debugPrint('⚠️ Documento de usuario no existe en Firestore');
      }
    } catch (e) {
      debugPrint('❌ Error al cargar datos del usuario: $e');
    }
  }

  /// Obtiene el usuario actualmente autenticado
  User? get currentUser => _auth.currentUser;

  /// Obtiene los datos del usuario actual
  Future<Usuario?> getUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await cargarDatosUsuario(currentUser.uid);
      return usuario.value;
    }
    return null;
  }

  /// Actualiza los datos del usuario
  Future<bool> updateUserData({
    String? nombre,
    String? email,
    String? currentPassword,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      isLoading.value = true;

      // Si se cambia el email, validar y enviar verificación
      if (email != null && email != currentUser.email) {
        // Re-autenticar si se proporciona la contraseña actual
        if (currentPassword != null && currentUser.email != null) {
          final credential = EmailAuthProvider.credential(
            email: currentUser.email!,
            password: currentPassword,
          );
          await currentUser.reauthenticateWithCredential(credential);
        }

        // Verificar el email actual antes de permitir cambio
        await currentUser.verifyBeforeUpdateEmail(email);

        // CRÍTICO: Guardar el email NUEVO en AuthStorage INMEDIATAMENTE
        // para que el auto-login use el email correcto cuando el token expire
        final authData = _authStorage.readAuthData();
        if (authData != null && authData['password'] != null) {
          await _authStorage.saveAuthData(email, authData['password']!);
          debugPrint(
            '💾 Email nuevo guardado en AuthStorage para auto-login: $email',
          );
        }

        // Mostrar mensaje de que debe verificar su email
        Get.snackbar(
          '📧 Verificación enviada',
          'Revisa tu bandeja de entrada de $email y haz clic en el enlace de verificación.\n\n'
              'Una vez verificado, los cambios se aplicarán automáticamente cuando regreses a la app.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 7),
          margin: const EdgeInsets.all(16),
          snackPosition: SnackPosition.TOP,
          isDismissible: true,
        );

        isLoading.value = false;
        return true;
      }

      // Actualizar solo nombre en Firestore
      final updates = <String, dynamic>{};
      if (nombre != null) updates['nombre'] = nombre;

      if (updates.isNotEmpty) {
        await _firestore
            .collection(usuariosColeccion)
            .doc(currentUser.uid)
            .update(updates);

        // Actualizar localmente
        if (usuario.value != null) {
          usuario.value = Usuario(
            nombre: nombre ?? usuario.value!.nombre,
            fechaNacimiento: usuario.value!.fechaNacimiento,
            email: usuario.value!.email,
          );
        }
      }

      Get.snackbar(
        'Éxito',
        'Los cambios se han realizado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      String mensaje = 'No se pudieron actualizar los datos';
      if (e.code == 'requires-recent-login') {
        mensaje =
            'Por seguridad, debes iniciar sesión nuevamente para cambiar tu correo';
      } else if (e.code == 'email-already-in-use') {
        mensaje = 'Este correo electrónico ya está en uso';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El formato del correo electrónico no es válido';
      } else if (e.code == 'wrong-password') {
        mensaje = 'La contraseña actual es incorrecta';
      }

      debugPrint('Error de Firebase Auth: ${e.code} - ${e.message}');
      Get.snackbar(
        'Error',
        mensaje,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading.value = false;
      return false;
    } catch (e) {
      debugPrint('Error al actualizar datos: $e');
      Get.snackbar(
        'Error',
        'No se pudieron actualizar los datos',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading.value = false;
      return false;
    }
  }

  /// Verifica manualmente si el usuario ha confirmado el cambio de email
  /// Este método ahora verifica y actualiza sin cerrar sesión
  Future<bool> checkAndUpdateEmailChange() async {
    await _checkEmailVerificationAndUpdate();
    return true;
  }

  /// Reenvía el correo de verificación para cambio de email
  Future<bool> resendEmailVerification() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      isLoading.value = true;

      // Firebase maneja automáticamente el reenvío de verificación
      // Solo necesitamos informar al usuario
      Get.snackbar(
        'Información',
        'Si hay un cambio de email pendiente, puedes solicitarlo nuevamente desde el formulario de edición',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );

      isLoading.value = false;
      return true;
    } catch (e) {
      debugPrint('Error al reenviar verificación: $e');
      Get.snackbar(
        'Error',
        'No se pudo reenviar el correo de verificación',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading.value = false;
      return false;
    }
  }

  /// Cambia la contraseña del usuario
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return false;

      isLoading.value = true;

      // Re-autenticar al usuario
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Cambiar contraseña en Firebase Authentication
      await user.updatePassword(newPassword);

      // Actualizar credenciales guardadas
      await _authStorage.saveAuthData(user.email!, newPassword);

      Get.snackbar(
        'Éxito',
        'Los cambios se han realizado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al cambiar la contraseña';
      if (e.code == 'wrong-password') {
        mensaje = 'La contraseña actual es incorrecta';
      } else if (e.code == 'weak-password') {
        mensaje = 'La nueva contraseña es demasiado débil';
      } else if (e.code == 'requires-recent-login') {
        mensaje =
            'Por seguridad, debes iniciar sesión nuevamente para cambiar tu contraseña';
      }

      Get.snackbar(
        'Error',
        mensaje,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading.value = false;
      return false;
    } catch (e) {
      debugPrint('Error al cambiar contraseña: $e');
      Get.snackbar(
        'Error',
        'Ocurrió un error al cambiar la contraseña',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading.value = false;
      return false;
    }
  }
}
