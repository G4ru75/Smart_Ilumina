import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/habitaciones_controller.dart';
import 'package:smart_ilumina/controllers/luz_controller.dart';
import 'package:smart_ilumina/models/Horarios_models.dart';
import 'package:smart_ilumina/models/luces_models.dart';

class HorariosController extends GetxController {
  final String nombreColeccion = 'luces';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final lucesController = Get.find<LucesController>();
  final habitacionesController = Get.find<HabitacionesController>();

  // Timer para verificar horarios
  Timer? _scheduler;

  // Cache para evitar aplicar el mismo horario múltiples veces
  final Map<String, DateTime> _ultimoHorarioAplicado = {};

  @override
  void onInit() {
    super.onInit();
    _iniciarScheduler();
  }

  @override
  void onClose() {
    _detenerScheduler();
    _ultimoHorarioAplicado.clear();
    super.onClose();
  }

  /// Iniciar verificador de horarios
  void _iniciarScheduler() {
    _scheduler?.cancel();

    _scheduler = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _verificarYAplicarHorarios(),
    );

    // Primera ejecución inmediata
    _verificarYAplicarHorarios();
  }

  /// Detener verificador de horarios
  void _detenerScheduler() {
    _scheduler?.cancel();
    _scheduler = null;
  }

  /// Verificar y aplicar horarios cada tick
  Future<void> _verificarYAplicarHorarios() async {
    try {
      // Obtener IDs de habitaciones del usuario
      final habitacionIds = habitacionesController.habitacionesList
          .map((h) => h.id)
          .where((id) => id.isNotEmpty)
          .toList();

      if (habitacionIds.isEmpty) return;

      // Consultar todas las luces vinculadas con horarios activos
      final querySnapshot = await _firestore
          .collection(nombreColeccion)
          .where('idHabitacion', whereIn: habitacionIds)
          .where('vinculada', isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) return;

      final now = DateTime.now();
      final horaActual = TimeOfDay.fromDateTime(now);
      final diaActual = now.weekday; // 1=Lunes, 7=Domingo

      final batch = _firestore.batch();
      bool hayCambios = false;

      for (final doc in querySnapshot.docs) {
        final luz = Luces.fromMap(doc.data());

        // Si no tiene horarios continua
        if (luz.horarios.isEmpty) continue;

        for (final horario in luz.horarios) {
          if (!horario.activo) continue;
          if (!horario.diasSemana.contains(diaActual)) continue;

          // Verificar si ya se aplicó este horario en el mismo minuto
          final cacheKey = '${luz.id}-${horario.id}';
          final ultimaAplicacion = _ultimoHorarioAplicado[cacheKey];

          if (ultimaAplicacion != null) {
            final mismoMinuto =
                ultimaAplicacion.year == now.year &&
                ultimaAplicacion.month == now.month &&
                ultimaAplicacion.day == now.day &&
                ultimaAplicacion.hour == now.hour &&
                ultimaAplicacion.minute == now.minute;

            if (mismoMinuto) continue;
          }

          // Verificar si debe encender o apagar
          final encender = _horaExacta(horaActual, horario.horaEncendido);
          final apagar = _horaExacta(horaActual, horario.horaApagado);

          bool? nuevoEstado;

          if (encender) {
            nuevoEstado = true;
          } else if (apagar) {
            nuevoEstado = false;
          }

          if (nuevoEstado != null) {
            // Actualizar en Firebase
            batch.update(doc.reference, {'encendida': nuevoEstado});

            _ultimoHorarioAplicado[cacheKey] = now;
            hayCambios = true;

            break;
          }
        }
      }

      if (hayCambios) {
        await batch.commit();
      }
    } catch (e, stackTrace) {
      print('Error en scheduler de horarios: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Verificar si la hora actual coincide exactamente con la programada
  bool _horaExacta(TimeOfDay actual, TimeOfDay programada) {
    return actual.hour == programada.hour && actual.minute == programada.minute;
  }

  /// Agregar nuevo horario a una luz
  Future<void> agregarHorario(String luzId, Horarios horario) async {
    try {
      final docSnapshot = await _firestore
          .collection(nombreColeccion)
          .doc(luzId)
          .get();

      if (!docSnapshot.exists) {
        Get.snackbar(
          'Error',
          'Luz no encontrada',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final luz = Luces.fromMap(docSnapshot.data()!);

      final nuevosHorarios = [...luz.horarios, horario];

      await _firestore.collection(nombreColeccion).doc(luzId).update({
        'horarios': nuevosHorarios.map((h) => h.toMap()).toList(),
      });

      Get.snackbar(
        'Horario agregado',
        'Horario agregado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e, stackTrace) {
      print('Error al agregar horario: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Ops, ha ocurrido un error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Eliminar un horario específico
  Future<void> eliminarHorario(String luzId, String horarioId) async {
    try {
      final docSnapshot = await _firestore
          .collection(nombreColeccion)
          .doc(luzId)
          .get();

      if (!docSnapshot.exists) {
        return;
      }

      final luz = Luces.fromMap(docSnapshot.data()!);

      final nuevosHorarios = luz.horarios
          .where((h) => h.id != horarioId)
          .toList();

      await _firestore.collection(nombreColeccion).doc(luzId).update({
        'horarios': nuevosHorarios.map((h) => h.toMap()).toList(),
      });

      Get.snackbar(
        'Horario eliminado',
        'El horario ha sido eliminado correctamente',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e, stackTrace) {
      print('Error al eliminar horario: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Ops, ha ocurrido un error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Activar o desactivar un horario
  Future<void> toggleHorario(
    String luzId,
    String horarioId,
    bool activo,
  ) async {
    try {
      final docSnapshot = await _firestore
          .collection(nombreColeccion)
          .doc(luzId)
          .get();

      if (!docSnapshot.exists) {
        return;
      }

      final luz = Luces.fromMap(docSnapshot.data()!);

      final nuevosHorarios = luz.horarios.map((h) {
        if (h.id == horarioId) {
          return Horarios(
            id: h.id,
            horaEncendido: h.horaEncendido,
            horaApagado: h.horaApagado,
            diasSemana: h.diasSemana,
            activo: activo,
          );
        }
        return h;
      }).toList();

      await _firestore.collection(nombreColeccion).doc(luzId).update({
        'horarios': nuevosHorarios.map((h) => h.toMap()).toList(),
      });

      Get.snackbar(
        activo ? 'Horario activado' : 'Horario desactivado',
        'Cambio aplicado correctamente',
        backgroundColor: activo ? Colors.green : Colors.grey,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e, stackTrace) {
      print('Error al toggle horario: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Ops, ha ocurrido un error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Editar un horario existente
  Future<void> editarHorario(String luzId, Horarios horarioEditado) async {
    try {
      final docSnapshot = await _firestore
          .collection(nombreColeccion)
          .doc(luzId)
          .get();

      if (!docSnapshot.exists) {
        Get.snackbar(
          'Error',
          'Luz no encontrada',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final luz = Luces.fromMap(docSnapshot.data()!);

      final nuevosHorarios = luz.horarios.map((h) {
        if (h.id == horarioEditado.id) {
          return horarioEditado;
        }
        return h;
      }).toList();

      await _firestore.collection(nombreColeccion).doc(luzId).update({
        'horarios': nuevosHorarios.map((h) => h.toMap()).toList(),
      });

      Get.snackbar(
        'Horario actualizado',
        'Los cambios se guardaron correctamente',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e, stackTrace) {
      print('Error al editar horario: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'No se pudo editar el horario: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
