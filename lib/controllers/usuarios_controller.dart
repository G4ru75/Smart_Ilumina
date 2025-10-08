import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_ilumina/models/usuarios_models.dart';

import 'package:smart_ilumina/controllers/habitaciones_controller.dart'; // <-- importar

class UsuariosController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final storage = GetStorage();

  // NO hagas Get.find() aquí
  late final HabitacionesController _habitacionesController;

  final Rxn<Usuario> usuario = Rxn<Usuario>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Resolver el controlador ya registrado
    if (Get.isRegistered<HabitacionesController>()) {
      _habitacionesController = Get.find<HabitacionesController>();
    } else {
      // Evita crashear si aún no está registrado
      ever(isLoading, (_) {}); // no-op para mantener el ciclo
    }

    _autoLogin();
  }

  void _autoLogin() {
    final String? email = storage.read('email');
    final String? contrasena = storage.read('contrasena');
    if (email != null &&
        contrasena != null &&
        email.isNotEmpty &&
        contrasena.isNotEmpty) {
      // No mostrar feedback visual en auto login silencioso
      loginUsuario(email, contrasena, showFeedback: false);
    try {
      final email = storage.read<String>('email');
      final contrasena = storage.read<String>('contrasena');
      if (email != null && contrasena != null) {
        loginUsuario(email, contrasena);
      }
    } catch (_) {
      // ignora si GetStorage no está listo
    }
  }

  Future<bool> loginUsuario(
    String email,
    String contrasena, {
    bool showFeedback = true,
  }) async {
    try {
      isLoading.value = true;

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: contrasena,
      );
      storage.write('email', email);
      storage.write('contrasena', contrasena);
      if (showFeedback) {
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
      isLoading.value = false;
      if (showFeedback) {
        Get.snackbar(
          'Error',
          e.message ?? 'Error desconocido',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      await storage.write('email', email);
      await storage.write('contrasena', contrasena);

      // Cargar habitaciones (si el controlador existe)
      if (Get.isRegistered<HabitacionesController>()) {
        _habitacionesController = Get.find<HabitacionesController>();
        await _habitacionesController.cargarHabitacionesUsuario();
      }

      Get.snackbar(
        'Exito',
        'Inicio de sesión exitoso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message ?? 'Error desconocido',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } catch (e, s) {
      debugPrint('Login post-auth error: $e\n$s');
      Get.snackbar(
        'Error',
        'Ocurrió un problema al continuar',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

      // Opcional: precargar habitaciones (vacío)
      if (Get.isRegistered<HabitacionesController>()) {
        _habitacionesController = Get.find<HabitacionesController>();
        await _habitacionesController.cargarHabitacionesUsuario();
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
}
