import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/models/habitaciones_models.dart';
import 'package:smart_ilumina/models/luces_models.dart';

class HabitacionesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Debounce por luz para evitar muchas escrituras al arrastrar intensidad
  final Map<String, Timer> _debouncers = {};

  var habitacionesList = <Habitaciones>[].obs;
  var isLoading = false.obs;

  String? get currentUserId => _auth.currentUser?.uid;

  // Clave única por luz para debounce (habitacionId-luzId)
  String _keyLuz(String habitacionId, String luzId) => '$habitacionId-$luzId';

  @override
  void onInit() {
    super.onInit();
    if (currentUserId != null) {
      cargarHabitacionesUsuario();
    }
  }

  // Cargar habitaciones del usuario actual desde Firebase
  Future<void> cargarHabitacionesUsuario() async {
    final uid = currentUserId;
    if (uid == null) return;

    try {
      isLoading.value = true;

      final QuerySnapshot snapshot = await _firestore
          .collection('habitaciones')
          .where('idUsuario', isEqualTo: uid)
          .get();

      final List<Habitaciones> habitaciones = snapshot.docs
          .map(
            (doc) =>
                Habitaciones.fromFirebase(doc.data() as Map<String, dynamic>),
          )
          .toList();

      // Actualizar progreso y ordenar en memoria (opcional)
      for (var h in habitaciones) {
        h.actualizarProgreso();
      }
      habitaciones.sort(
        (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
      );

      habitacionesList
        ..clear()
        ..addAll(habitaciones);
    } catch (e) {
      Get.snackbar('Error', 'Error al cargar habitaciones: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Guardar/crear habitación en Firebase (helper)
  Future<void> _guardarHabitacion(Habitaciones habitacion) async {
    try {
      await _firestore
          .collection('habitaciones')
          .doc(habitacion.id)
          .set(habitacion.toMap());
    } catch (e) {
      Get.snackbar('Error', 'Error al guardar habitación: $e');
    }
  }

  // Actualizar habitación en Firebase (helper)
  Future<void> _actualizarHabitacionEnFirebase(Habitaciones habitacion) async {
    try {
      await _firestore
          .collection('habitaciones')
          .doc(habitacion.id)
          .update(habitacion.toMap());
    } catch (e) {
      debugPrint('Error actualizando habitación en Firebase: $e');
    }
  }

  // Agregar nueva habitación con luces estáticas
  Future<void> agregarHabitacion(
    String nombre, {
    IconData? icon,
    Color? color,
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      Get.snackbar('Error', 'Debe estar autenticado para agregar habitaciones');
      return;
    }

    if (nombre.trim().isEmpty) {
      Get.snackbar('Error', 'El nombre de la habitación no puede estar vacío');
      return;
    }

    try {
      final nuevaHabitacion = Habitaciones(
        idUsuario: uid,
        nombre: nombre.trim(),
        icon: icon ?? Icons.home,
        color: color ?? Colors.purple,
        luces: [],
      );

      // Crear luces estáticas para la habitación
      final lucesEstaticas = _crearLucesEstaticas(nuevaHabitacion.id);
      nuevaHabitacion.luces.addAll(lucesEstaticas);
      nuevaHabitacion.actualizarProgreso();

      // Guardar en Firebase y en memoria
      await _guardarHabitacion(nuevaHabitacion);
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
        horaEncendido: const TimeOfDay(hour: 18, minute: 0),
        horaApagado: const TimeOfDay(hour: 23, minute: 0),
      ),
      Luces(
        id: UniqueKey().toString(),
        nombre: 'Luz Secundaria',
        encendida: false,
        intensidad: 0.5,
        color: Colors.white,
        idHabitacion: habitacionId,
        vinculada: true,
        horaEncendido: const TimeOfDay(hour: 18, minute: 0),
        horaApagado: const TimeOfDay(hour: 23, minute: 0),
      ),
      Luces(
        id: UniqueKey().toString(),
        nombre: 'Luz Ambiente',
        encendida: true,
        intensidad: 0.3,
        color: Colors.blue,
        idHabitacion: habitacionId,
        vinculada: true,
        horaEncendido: const TimeOfDay(hour: 18, minute: 0),
        horaApagado: const TimeOfDay(hour: 23, minute: 0),
      ),
    ];
  }

  // Configurar luz (actualiza inmediatamente en Firebase)
  Future<void> configurarLuz(
    int habitacionIndex,
    int luzIndex, {
    bool? encendida,
    double? intensidad,
    Color? color,
    TimeOfDay? horaEncendido,
    TimeOfDay? horaApagado,
  }) async {
    if (habitacionIndex < 0 || habitacionIndex >= habitacionesList.length)
      return;
    final habitacion = habitacionesList[habitacionIndex];
    if (luzIndex < 0 || luzIndex >= habitacion.luces.length) return;

    final luz = habitacion.luces[luzIndex];

    if (encendida != null) luz.encendida = encendida;
    if (intensidad != null) luz.intensidad = intensidad.clamp(0.0, 1.0);
    if (color != null) luz.color = color;
    if (horaEncendido != null) luz.horaEncendido = horaEncendido;
    if (horaApagado != null) luz.horaApagado = horaApagado;

    habitacion.actualizarProgreso();

    await _actualizarHabitacionEnFirebase(habitacion);
    habitacionesList.refresh();
  }

  // Cambiar estado de una luz (on/off) y actualizar en Firebase
  Future<void> cambiarEstadoLuz(
    int habitacionIndex,
    int luzIndex,
    bool encendida,
  ) async {
    if (habitacionIndex < 0 || habitacionIndex >= habitacionesList.length)
      return;
    final habitacion = habitacionesList[habitacionIndex];
    if (luzIndex < 0 || luzIndex >= habitacion.luces.length) return;

    habitacion.luces[luzIndex].encendida = encendida;
    habitacion.actualizarProgreso();

    await _actualizarHabitacionEnFirebase(habitacion);
    habitacionesList.refresh();
  }

  // Cambiar color de una luz y actualizar en Firebase
  Future<void> cambiarColorLuz(
    int habitacionIndex,
    int luzIndex,
    Color color,
  ) async {
    if (habitacionIndex < 0 || habitacionIndex >= habitacionesList.length)
      return;
    final habitacion = habitacionesList[habitacionIndex];
    if (luzIndex < 0 || luzIndex >= habitacion.luces.length) return;

    habitacion.luces[luzIndex].color = color;
    await _actualizarHabitacionEnFirebase(habitacion);
    habitacionesList.refresh();
  }

  // Cambiar intensidad con debounce para no saturar escrituras
  void cambiarIntensidadLuzDebounced(
    int habitacionIndex,
    int luzIndex,
    double value,
  ) {
    if (habitacionIndex < 0 || habitacionIndex >= habitacionesList.length)
      return;
    final habitacion = habitacionesList[habitacionIndex];
    if (luzIndex < 0 || luzIndex >= habitacion.luces.length) return;

    final luz = habitacion.luces[luzIndex];
    luz.intensidad = value.clamp(0.0, 1.0);

    final key = _keyLuz(habitacion.id, luz.id);
    _debouncers[key]?.cancel();
    _debouncers[key] = Timer(const Duration(milliseconds: 180), () async {
      await _actualizarHabitacionEnFirebase(habitacion);
      _debouncers.remove(key);
    });

    habitacionesList.refresh();
  }

  // Cambiar horas programadas y actualizar en Firebase
  Future<void> cambiarHorasLuz(
    int habitacionIndex,
    int luzIndex, {
    TimeOfDay? horaEncendido,
    TimeOfDay? horaApagado,
  }) async {
    if (habitacionIndex < 0 || habitacionIndex >= habitacionesList.length)
      return;
    final habitacion = habitacionesList[habitacionIndex];
    if (luzIndex < 0 || luzIndex >= habitacion.luces.length) return;

    final luz = habitacion.luces[luzIndex];
    if (horaEncendido != null) luz.horaEncendido = horaEncendido;
    if (horaApagado != null) luz.horaApagado = horaApagado;

    await _actualizarHabitacionEnFirebase(habitacion);
    habitacionesList.refresh();
  }

  // Cambiar estado de todas las luces de una habitación y actualizar en Firebase
  Future<void> cambiarEstadoTodasLuces(
    int habitacionIndex,
    bool encendida,
  ) async {
    if (habitacionIndex < 0 || habitacionIndex >= habitacionesList.length)
      return;
    final habitacion = habitacionesList[habitacionIndex];

    for (var luz in habitacion.luces) {
      luz.encendida = encendida;
    }
    habitacion.actualizarProgreso();

    await _actualizarHabitacionEnFirebase(habitacion);
    habitacionesList.refresh();
  }

  // Recargar habitaciones (pull-to-refresh)
  Future<void> recargarHabitaciones() async {
    await cargarHabitacionesUsuario();
  }

  // Limpiar datos al cerrar sesión
  void limpiarDatos() {
    // Cancelar debouncers pendientes
    for (final t in _debouncers.values) {
      t.cancel();
    }
    _debouncers.clear();

    habitacionesList.clear();
    isLoading.value = false;
  }

  // Obtener habitación por índice
  Habitaciones? obtenerHabitacion(int index) {
    if (index >= 0 && index < habitacionesList.length)
      return habitacionesList[index];
    return null;
  }

  // Agrega una nueva luz a una habitación y persiste inmediatamente
  Future<void> agregarLuzAHabitacion({
    required int habitacionIndex,
    required Luces luz,
  }) async {
    if (habitacionIndex < 0 || habitacionIndex >= habitacionesList.length)
      return;
    final habitacion = habitacionesList[habitacionIndex];

    habitacion.luces.add(luz);
    habitacion.actualizarProgreso();

    await _actualizarHabitacionEnFirebase(habitacion);
    habitacionesList.refresh();
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
