import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/models/habitaciones_models.dart';
import 'package:smart_ilumina/models/luces_models.dart';

class HabitacionesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var habitacionesList = <Habitaciones>[].obs;
  var isLoading = false.obs;

  String? get currentUserId => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    if (currentUserId != null) {
      cargarHabitacionesUsuario();
    }
  }

  // Cargar habitaciones del usuario actual desde Firebase
  Future<void> cargarHabitacionesUsuario() async {
    if (currentUserId == null) {
      return;
    }

    try {
      isLoading.value = true;

      final QuerySnapshot snapshot = await _firestore
          .collection('habitaciones')
          .where('idUsuario', isEqualTo: currentUserId)
          .get();

      habitacionesList.clear();

      final List<Habitaciones> habitaciones = snapshot.docs
          .map(
            (doc) =>
                Habitaciones.fromFirebase(doc.data() as Map<String, dynamic>),
          )
          .toList();

      habitacionesList.addAll(habitaciones);

      // Actualizar progreso de cada habitación
      for (var habitacion in habitacionesList) {
        habitacion.actualizarProgreso();
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al cargar habitaciones: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Agregar nueva habitación con luces estáticas
  Future<void> agregarHabitacion(
    String nombre, {
    IconData? icon,
    Color? color,
  }) async {
    if (currentUserId == null) {
      Get.snackbar('Error', 'Debe estar autenticado para agregar habitaciones');
      return;
    }

    if (nombre.trim().isEmpty) {
      Get.snackbar('Error', 'El nombre de la habitación no puede estar vacío');
      return;
    }

    try {
      final nuevaHabitacion = Habitaciones(
        idUsuario: currentUserId!,
        nombre: nombre.trim(),
        icon: icon ?? Icons.room,
        color: color ?? Colors.purple,
        luces: [], // Se creará después
      );

      // Crear luces estáticas para la habitación
      final lucesEstaticas = _crearLucesEstaticas(nuevaHabitacion.id);
      nuevaHabitacion.luces.addAll(lucesEstaticas);
      nuevaHabitacion.actualizarProgreso();

      // Guardar en Firebase
      await _firestore
          .collection('habitaciones')
          .doc(nuevaHabitacion.id)
          .set(nuevaHabitacion.toMap());

      // Agregar a la lista local
      habitacionesList.add(nuevaHabitacion);

      Get.snackbar(
        'Éxito',
        'Habitación "$nombre" creada con ${lucesEstaticas.length} luces',
      );
    } catch (e) {
      Get.snackbar('Error', 'Error al crear habitación: $e');
    }
  }

  // Crear luces estáticas para una habitación
  List<Luces> _crearLucesEstaticas(String habitacionId) {
    return [
      Luces(
        id: UniqueKey().toString(),
        nombre: 'Luz Principal',
        encendida: true,
        intensidad: 0.8,
        color: Colors.amber,
        idHabitacion: habitacionId,
        vinculada: true,
      ),
      Luces(
        id: UniqueKey().toString(),
        nombre: 'Luz Secundaria',
        encendida: false,
        intensidad: 0.5,
        color: Colors.white,
        idHabitacion: habitacionId,
        vinculada: true,
      ),
      Luces(
        id: UniqueKey().toString(),
        nombre: 'Luz Ambiente',
        encendida: true,
        intensidad: 0.3,
        color: Colors.blue,
        idHabitacion: habitacionId,
        vinculada: true,
      ),
    ];
  }

  // Configurar luz
  Future<void> configurarLuz(
    int habitacionIndex,
    int luzIndex, {
    bool? encendida,
    double? intensidad,
    Color? color,
  }) async {
    if (habitacionIndex >= 0 && habitacionIndex < habitacionesList.length) {
      final habitacion = habitacionesList[habitacionIndex];

      if (luzIndex >= 0 && luzIndex < habitacion.luces.length) {
        final luz = habitacion.luces[luzIndex];

        if (encendida != null) luz.encendida = encendida;
        if (intensidad != null) luz.intensidad = intensidad.clamp(0.0, 1.0);
        if (color != null) luz.color = color;

        habitacion.actualizarProgreso();

        // Actualizar en Firebase
        await _actualizarHabitacionEnFirebase(habitacion);

        habitacionesList.refresh();
      }
    }
  }

  // Cambiar estado de una luz
  Future<void> cambiarEstadoLuz(
    int habitacionIndex,
    int luzIndex,
    bool encendida,
  ) async {
    if (habitacionIndex >= 0 && habitacionIndex < habitacionesList.length) {
      final habitacion = habitacionesList[habitacionIndex];

      if (luzIndex >= 0 && luzIndex < habitacion.luces.length) {
        habitacion.luces[luzIndex].encendida = encendida;
        habitacion.actualizarProgreso();

        await _actualizarHabitacionEnFirebase(habitacion);
        habitacionesList.refresh();
      }
    }
  }

  // Cambiar estado de todas las luces de una habitación
  Future<void> cambiarEstadoTodasLuces(
    int habitacionIndex,
    bool encendida,
  ) async {
    if (habitacionIndex >= 0 && habitacionIndex < habitacionesList.length) {
      final habitacion = habitacionesList[habitacionIndex];

      for (var luz in habitacion.luces) {
        luz.encendida = encendida;
      }

      habitacion.actualizarProgreso();
      await _actualizarHabitacionEnFirebase(habitacion);
      habitacionesList.refresh();
    }
  }

  // Actualizar habitación en Firebase
  Future<void> _actualizarHabitacionEnFirebase(Habitaciones habitacion) async {
    try {
      await _firestore
          .collection('habitaciones')
          .doc(habitacion.id)
          .update(habitacion.toMap());
    } catch (e) {
      print('Error actualizando habitación en Firebase: $e');
    }
  }

  // Eliminar habitación
  Future<void> eliminarHabitacion(int index) async {
    if (index >= 0 && index < habitacionesList.length) {
      final habitacion = habitacionesList[index];

      try {
        await _firestore.collection('habitaciones').doc(habitacion.id).delete();
        habitacionesList.removeAt(index);
        Get.snackbar('Éxito', 'Habitación eliminada correctamente');
      } catch (e) {
        Get.snackbar('Error', 'Error al eliminar habitación: $e');
      }
    }
  }

  // Recargar habitaciones
  Future<void> recargarHabitaciones() async {
    await cargarHabitacionesUsuario();
  }

  // Limpiar datos al cerrar sesión
  void limpiarDatos() {
    habitacionesList.clear();
    isLoading.value = false;
  }

  // Obtener habitación por índice
  Habitaciones? obtenerHabitacion(int index) {
    if (index >= 0 && index < habitacionesList.length) {
      return habitacionesList[index];
    }
    return null;
  }

  // Estadísticas para las InfoCards
  String cantidadLuces() {
    if (habitacionesList.isEmpty) return '0/0';

    final totalLuces = habitacionesList.fold<int>(
      0,
      (sum, h) => sum + h.luces.length,
    );
    final totalEncendidas = habitacionesList.fold<int>(
      0,
      (sum, h) => sum + h.luces.where((l) => l.encendida).length,
    );

    return '$totalEncendidas/$totalLuces';
  }

  int get totalHabitaciones => habitacionesList.length;
  int get totalLuces =>
      habitacionesList.fold(0, (sum, h) => sum + h.luces.length);
  int get lucesEncendidas => habitacionesList.fold(
    0,
    (sum, h) => sum + h.luces.where((l) => l.encendida).length,
  );
}
