import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_ilumina/models/usuarios_models.dart';
import 'package:smart_ilumina/utils/auth_storage.dart';

import 'package:smart_ilumina/controllers/habitaciones_controller.dart'; // <-- importar

class UsuariosController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final storage = GetStorage();
  final AuthStorage _authStorage = AuthStorage();

  final Rxn<Usuario> usuario = Rxn<Usuario>();
  var isLoading = false.obs;
  var isCheckingSession = false.obs; // Para el splash inicial

  @override
  void onInit() {
    super.onInit();
    // El auto-login ahora se maneja desde main.dart antes de runApp
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
          .collection('usuarios')
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
      final doc = await _firestore.collection('usuarios').doc(uid).get();
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
  Future<bool> updateUserData({String? nombre, String? email}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      isLoading.value = true;

      // Actualizar en Firestore
      final updates = <String, dynamic>{};
      if (nombre != null) updates['nombre'] = nombre;
      if (email != null) updates['email'] = email;

      if (updates.isNotEmpty) {
        await _firestore
            .collection('usuarios')
            .doc(currentUser.uid)
            .update(updates);

        // Actualizar localmente
        if (usuario.value != null) {
          usuario.value = Usuario(
            nombre: nombre ?? usuario.value!.nombre,
            fechaNacimiento: usuario.value!.fechaNacimiento,
            email: email ?? usuario.value!.email,
          );
        }
      }

      Get.snackbar(
        'Éxito',
        'Datos actualizados correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      isLoading.value = false;
      return true;
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

      // Cambiar contraseña
      await user.updatePassword(newPassword);

      // Actualizar credenciales guardadas
      await _authStorage.saveAuthData(user.email!, newPassword);

      Get.snackbar(
        'Éxito',
        'Contraseña actualizada correctamente',
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
