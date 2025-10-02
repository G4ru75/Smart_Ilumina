import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_ilumina/models/usuarios_models.dart';

import '../models/usuarios_models.dart';

class UsuariosController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final storage = GetStorage();
  final Rxn<Usuario> usuario = Rxn<Usuario>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    autoLogin();
  }

  void autoLogin() {
    String? email = storage.read('email');
    String? contrasena = storage.read('contrasena');
    if (email != null && contrasena != null) {
      loginUsuario(email, contrasena);
    }
  }

  Future<bool> loginUsuario(String email, String contrasena) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: contrasena,
      );
      storage.write('email', email);
      storage.write('contrasena', contrasena);
      return true;
      Get.snackbar(
        'Exito',
        'Inicio de sesión exitoso',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      isLoading.value = false;
    } on FirebaseAuthException catch (e) {
      return false;
      isLoading.value = false;
      Get.snackbar(
        'Error',
        e.message ?? 'Error desconocido',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: contrasena);

      Usuario nuevoUsuario = Usuario(
        nombre: nombre,
        fechaNacimiento: fechaNacimiento,
        email: email,
      );

      await _firestore
          .collection('usuarios')
          .doc(userCredential.user?.uid)
          .set(nuevoUsuario.toMap());

      Get.snackbar(
        'Éxito',
        'Usuario registrado exitosamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      isLoading.value = false;
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message ?? 'Error desconocido',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al registrar usuario',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
