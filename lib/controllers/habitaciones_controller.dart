import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/models/habitaciones_models.dart';

class HabitacionesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String habitacionesColeccion = 'habitaciones';
  // Estado de habitaciones
  final RxList<Habitaciones> habitacionesList = <Habitaciones>[].obs;
  final RxBool isLoading = false.obs;

  // Stream de habitaciones
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _habSub;

  String? get currentUserId => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();

    // Reacciona a cambios de sesión
    _auth.userChanges().listen((user) {
      if (user == null) {
        limpiarDatos();
      } else {
        cargarHabitacionesUsuario();
      }
    });

    // Si ya hay sesión al iniciar
    if (currentUserId != null) {
      cargarHabitacionesUsuario();
    }
  }

  @override
  void onClose() {
    _detenerStream();
    super.onClose();
  }

  // Escuchar habitaciones del usuario en tiempo real
  Future<void> cargarHabitacionesUsuario() async {
    final uid = currentUserId;
    if (uid == null) return;

    await _habSub?.cancel();
    isLoading.value = true;

    _habSub = _firestore
        .collection(habitacionesColeccion)
        .where('idUsuario', isEqualTo: uid)
        .snapshots()
        .listen(
          (snap) {
            final lista = snap.docs
                .where((d) => d.exists && d.data().isNotEmpty)
                .map((d) => Habitaciones.fromFirebase(d.data()))
                .toList();

            // Orden opcional por nombre
            lista.sort(
              (a, b) =>
                  a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
            );

            habitacionesList.assignAll(lista);
            isLoading.value = false;
          },
          onError: (e) {
            isLoading.value = false;
            Get.snackbar('Habitaciones', 'Error al escuchar habitaciones: $e');
          },
        );
  }

  // Crear habitación (sin array de luces en el doc)
  Future<void> agregarHabitacion(
    String nombre, {
    IconData? icon,
    Color? color,
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      Get.snackbar('Habitaciones', 'Debe estar autenticado');
      return;
    }
    if (nombre.trim().isEmpty) {
      Get.snackbar('Habitaciones', 'El nombre no puede estar vacío');
      return;
    }

    try {
      final id = _firestore.collection(habitacionesColeccion).doc().id;
      final data = {
        'id': UniqueKey().toString(),
        'idUsuario': uid,
        'nombre': nombre.trim(),
        if (icon != null) 'icon': icon.codePoint,
        if (color != null) 'color': color.value,
        'createdAt': FieldValue.serverTimestamp(),
        // Importante: no guardar campo "luces"
      };

      await _firestore.collection(habitacionesColeccion).doc(id).set(data);
      Get.snackbar('Habitaciones', 'Habitación "$nombre" creada');
      // El stream actualizará habitacionesList
    } catch (e) {
      Get.snackbar('Habitaciones', 'No se pudo crear: $e');
    }
  }

  // Actualizar datos básicos de la habitación
  Future<void> actualizarHabitacion(
    String habitacionId, {
    String? nombre,
    IconData? icon,
    Color? color,
  }) async {
    final data = <String, dynamic>{};
    if (nombre != null) data['nombre'] = nombre.trim();
    if (icon != null) data['icon'] = icon.codePoint;
    if (color != null) data['color'] = color.value;

    if (data.isEmpty) return;

    try {
      await _firestore
          .collection(habitacionesColeccion)
          .doc(habitacionId)
          .update(data);
      Get.snackbar('Habitaciones', 'Habitación actualizada');
    } catch (e) {
      Get.snackbar('Habitaciones', 'No se pudo actualizar: $e');
    }
  }

  // Eliminar habitación (no toca colección luces)
  Future<void> eliminarHabitacion(String habitacionId) async {
    try {
      await _firestore
          .collection(habitacionesColeccion)
          .doc(habitacionId)
          .delete();
      Get.snackbar('Habitaciones', 'Habitación eliminada');
      // El stream removerá la habitación de la lista
    } catch (e) {
      Get.snackbar('Habitaciones', 'No se pudo eliminar: $e');
    }
  }

  // Recargar (reinicia el stream)
  Future<void> recargarHabitaciones() async {
    await cargarHabitacionesUsuario();
  }

  // Limpiar datos (al cerrar sesión)
  void limpiarDatos() {
    _detenerStream();
    habitacionesList.clear();
    isLoading.value = false;
  }

  void _detenerStream() {
    _habSub?.cancel();
    _habSub = null;
  }

  // Obtener habitación por índice
  Habitaciones? obtenerHabitacion(int index) {
    if (index >= 0 && index < habitacionesList.length)
      return habitacionesList[index];
    return null;
  }
}
