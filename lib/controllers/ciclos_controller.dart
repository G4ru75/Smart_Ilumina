import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/luz_controller.dart';
import 'package:smart_ilumina/models/ciclos_models.dart';
import 'package:smart_ilumina/models/luces_models.dart';

class CiclosController extends GetxController {
  final String nombreColeccion = 'luces';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final lucesController = Get.find<LucesController>();

  // Timers activos por cada luz con ciclo
  final Map<String, Timer> _cicloTimers = {};
  final Map<String, DateTime> _ultimoCambio = {};

  @override
  void onInit() {
    super.onInit();
    _startCiclosMonitoring();
  }

  @override
  void onClose() {
    _stopAllCiclos();
    super.onClose();
  }

  /// Configurar o actualizar ciclo para una luz
  Future<void> configurarCiclo({
    required String luzId,
    required int duracionEncendido, // segundos
    required int duracionApagado,
    bool activo = true,
  }) async {
    try {
      // Validaciones
      if (duracionEncendido < 1 || duracionApagado < 1) {
        Get.snackbar(
          'Error',
          'Las duraciones deben ser mayores a 0 segundos',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (duracionEncendido > 3600 || duracionApagado > 3600) {
        Get.snackbar(
          'Error',
          'Las duraciones no pueden superar 1 hora (3600 segundos)',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Obtener luz de Firebase
      final docSnapshot = await _firestore
          .collection(nombreColeccion)
          .doc(luzId)
          .get();

      if (!docSnapshot.exists) {
        Get.snackbar('Error', 'Luz no encontrada');
        return;
      }

      final ciclo = Ciclos(
        duracionEncendido: duracionEncendido,
        duracionApagado: duracionApagado,
        activo: true,
      );

      await _firestore.collection(nombreColeccion).doc(luzId).update({
        'ciclos': ciclo.toMap(),
      });

      Get.snackbar(
        'Ciclo configurado',
        'Encendido: ${duracionEncendido}s, Apagado: ${duracionApagado}s',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Iniciar el ciclo
      _iniciarCiclo(luzId, ciclo);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo configurar el ciclo: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Activar o desactivar ciclo existente
  Future<void> toggleCiclo(String luzId, bool activo) async {
    try {
      final docSnapshot = await _firestore
          .collection(nombreColeccion)
          .doc(luzId)
          .get();

      if (!docSnapshot.exists) {
        Get.snackbar('Error', 'Luz no encontrada');
        return;
      }

      final luz = Luces.fromMap(docSnapshot.data()!);

      if (luz.ciclos == null) {
        Get.snackbar(
          'Error',
          'Esta luz no tiene un ciclo configurado',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final cicloActualizado = Ciclos(
        duracionEncendido: luz.ciclos!.duracionEncendido,
        duracionApagado: luz.ciclos!.duracionApagado,
        activo: activo,
      );

      await _firestore.collection(nombreColeccion).doc(luzId).update({
        'ciclos': cicloActualizado.toMap(),
      });

      if (activo) {
        _iniciarCiclo(luzId, cicloActualizado);
        Get.snackbar(
          'Ciclo activado',
          'El ciclo se está ejecutando',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      } else {
        _detenerCiclo(luzId);
        Get.snackbar(
          'Ciclo desactivado',
          'El ciclo se ha detenido',
          backgroundColor: Colors.grey,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cambiar el estado del ciclo: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Eliminar ciclo de una luz
  Future<void> eliminarCiclo(String luzId) async {
    print('🗑️ Eliminando ciclo de luz: $luzId');

    try {
      await _firestore.collection(nombreColeccion).doc(luzId).update({
        'ciclos': null,
      });

      _detenerCiclo(luzId);

      Get.snackbar(
        'Ciclo eliminado',
        'El ciclo ha sido eliminado correctamente',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el ciclo: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Iniciar monitoreo de ciclos activos
  void _startCiclosMonitoring() {
    // Escuchar cambios en todas las luces con ciclos activos
    Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final snapshot = await _firestore
            .collection(nombreColeccion)
            .where('vinculada', isEqualTo: true)
            .get();

        for (final doc in snapshot.docs) {
          final luz = Luces.fromMap(doc.data());

          if (luz.ciclos != null && luz.ciclos!.activo) {
            // Si no hay timer activo lo crea
            if (!_cicloTimers.containsKey(luz.id)) {
              _iniciarCiclo(luz.id, luz.ciclos!);
            }
          } else {
            // Si hay timer pero no debería estar activo, detiene
            if (_cicloTimers.containsKey(luz.id)) {
              _detenerCiclo(luz.id);
            }
          }
        }
      } catch (e) {
        print('Error al monitorear ciclos: $e');
      }
    });
  }

  /// Iniciar ciclo para una luz específica
  void _iniciarCiclo(String luzId, Ciclos ciclo) {
    // Detener ciclo existente si hay uno
    _detenerCiclo(luzId);

    // Calcular duración total del ciclo
    final duracionTotal = ciclo.duracionEncendido + ciclo.duracionApagado;

    _cicloTimers[luzId] = Timer.periodic(Duration(seconds: duracionTotal), (
      timer,
    ) async {
      try {
        // Verificar si el ciclo sigue activo
        final docSnapshot = await _firestore
            .collection(nombreColeccion)
            .doc(luzId)
            .get();

        if (!docSnapshot.exists) {
          timer.cancel();
          return;
        }

        final luz = Luces.fromMap(docSnapshot.data()!);

        if (luz.ciclos == null || !luz.ciclos!.activo) {
          timer.cancel();
          _cicloTimers.remove(luzId);
          return;
        }

        // Encender luz
        await lucesController.cambiarEstadoLuz(luzId, true);

        // Esperar duración de encendido
        await Future.delayed(Duration(seconds: ciclo.duracionEncendido));

        await lucesController.cambiarEstadoLuz(luzId, false);

        _ultimoCambio[luzId] = DateTime.now();
      } catch (e) {
        print('Error en ciclo: $e');
      }
    });

    // Ejecutar primera iteración inmediatamente
    Future.delayed(Duration.zero, () async {
      try {
        await lucesController.cambiarEstadoLuz(luzId, true);
        await Future.delayed(Duration(seconds: ciclo.duracionEncendido));
        await lucesController.cambiarEstadoLuz(luzId, false);
      } catch (e) {
        print('Error en primera iteración: $e');
      }
    });
  }

  /// Detener ciclo de una luz específica
  void _detenerCiclo(String luzId) {
    if (_cicloTimers.containsKey(luzId)) {
      _cicloTimers[luzId]?.cancel();
      _cicloTimers.remove(luzId);
      _ultimoCambio.remove(luzId);
    }
  }

  /// Detener todos los ciclos
  void _stopAllCiclos() {
    for (final timer in _cicloTimers.values) {
      timer.cancel();
    }
    _cicloTimers.clear();
    _ultimoCambio.clear();
  }

  /// Obtener estado del ciclo de una luz
  bool isCicloActivo(String luzId) {
    return _cicloTimers.containsKey(luzId);
  }

  /// Obtener último cambio de estado
  DateTime? getUltimoCambio(String luzId) {
    return _ultimoCambio[luzId];
  }
}
