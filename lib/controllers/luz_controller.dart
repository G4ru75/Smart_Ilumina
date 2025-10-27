import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/habitaciones_controller.dart';
import 'package:smart_ilumina/models/luces_models.dart';
import 'package:smart_ilumina/utils/lucesProgreso.dart';

class LucesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String nombreColeccion = 'luces';
  final habitacionesController = Get.find<HabitacionesController>();

  // Estados
  final RxList<Luces> luces = <Luces>[].obs;
  final RxBool loading = false.obs;
  final RxnString error = RxnString();
  final RxnString habitacionActualId = RxnString();

  // Streams y timers
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  final Map<String, Timer> _debouncers = {}; // por luzId para intensidad

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    _cancelStream();
    _cancelAllDebouncers();
    super.onClose();
  }

  Stream<List<Luces>> lucesStreamDeHabitacion(String habitacionId) {
    return _firestore
        .collection(nombreColeccion)
        .where('idHabitacion', isEqualTo: habitacionId)
        .snapshots()
        .map(
          (qs) => qs.docs
              .where((d) => d.exists && d.data().isNotEmpty)
              .map((d) => Luces.fromMap(d.data()))
              .toList(),
        );
  }

  Stream<LucesProgreso> progresoHabitacion(String habitacionId) {
    return _firestore
        .collection(nombreColeccion)
        .where('idHabitacion', isEqualTo: habitacionId)
        .snapshots()
        .map((qs) {
          final total = qs.docs.length;
          final encendidas = qs.docs
              .where((d) => (d.data()['encendida'] ?? false) == true)
              .length;
          return LucesProgreso(total: total, encendidas: encendidas);
        });
  }

  Future<void> vincularALaHabitacion({
    required String luzId,
    required String habitacionId,
  }) async {
    try {
      await _firestore.collection(nombreColeccion).doc(luzId).update({
        'idHabitacion': habitacionId,
        'vinculada': true,
      });

      final idx = luces.indexWhere((l) => l.id == luzId);
      if (idx != -1) {
        luces[idx].idHabitacion = habitacionId;
        luces[idx].vinculada = true;
        luces.refresh();
        print('Se vincula la luz $luzId a la habitación $habitacionId');
      }
    } catch (e) {
      error.value = e.toString();
      rethrow;
    }
  }

  Future<void> escucharLucesDeHabitacion(String idHabitacion) async {
    if (idHabitacion.isEmpty) {
      luces.clear();
      return;
    }

    habitacionActualId.value = idHabitacion;
    await _cancelStream();

    loading.value = true;
    _sub = _firestore
        .collection(nombreColeccion)
        .where('idHabitacion', isEqualTo: idHabitacion)
        .snapshots()
        .listen(
          (snap) {
            try {
              luces.assignAll(
                snap.docs
                    .where((d) => d.exists && d.data().isNotEmpty)
                    .map((d) => Luces.fromMap(d.data()))
                    .toList(),
              );
            } catch (e) {
              error.value = e.toString();
            }
          },
          onError: (e) {
            error.value = e.toString();
          },
        );
  }

  Future<void> _cancelStream() async {
    await _sub?.cancel();
    _sub = null;
    luces.clear();
  }

  Future<void> cambiarEstadoLuz(String luzId, bool encendida) async {
    _setLocal(luzId, (l) => l.encendida = encendida);
    await _actualizarLuz(luzId, {'encendida': encendida});
  }

  Future<void> cambiarColor(String luzId, Color color) async {
    _setLocal(luzId, (l) => l.color = color);
    await _actualizarLuz(luzId, {'color': color.value});
  }

  void cambiarIntensidadDebounced(String luzId, double valor) {
    _setLocal(luzId, (l) => l.intensidad = valor.clamp(0.0, 1.0));

    _debouncers[luzId]?.cancel();
    _debouncers[luzId] = Timer(const Duration(milliseconds: 180), () async {
      await _actualizarLuz(luzId, {'intensidad': valor.clamp(0.0, 1.0)});
      _debouncers.remove(luzId);
    });
  }

  Stream<List<Luces>> todasLasLucesVinculadas() {
    try {
      final habitacionesController = Get.find<HabitacionesController>();

      if (habitacionesController.habitacionesList().isEmpty) {
        return Stream.value(<Luces>[]);
      }

      final habitacionesIds = habitacionesController
          .habitacionesList()
          .map((h) => h.id)
          .where((id) => id.isNotEmpty)
          .toList();

      if (habitacionesIds.isEmpty) {
        return Stream.value(<Luces>[]);
      }

      return _firestore
          .collection(nombreColeccion)
          .where('vinculada', isEqualTo: true)
          .where('idHabitacion', whereIn: habitacionesIds)
          .snapshots()
          .map(
            (querySnapshot) => querySnapshot.docs
                .where((doc) => doc.exists && doc.data().isNotEmpty)
                .map((doc) => Luces.fromMap(doc.data()))
                .toList(),
          );
    } catch (e) {
      Get.snackbar('Error', 'No se pudo obtener las luces vinculadas: $e');
      return Stream.value(<Luces>[]);
    }
  }

  Future<void> deshabilitarLuz(String luzId) async {
    try {
      await _firestore.collection(nombreColeccion).doc(luzId).update({
        'idHabitacion': null,
        'vinculada': false,
      });

      final idx = luces.indexWhere((l) => l.id == luzId);
      if (idx != -1) {
        luces[idx].idHabitacion = '';
        luces[idx].vinculada = false;
        luces.refresh();
      }
    } catch (e) {
      error.value = e.toString();
      rethrow;
    }
  }

  Future<void> cambiarEstadoTodas(bool encendida) async {
    final idHab = habitacionActualId.value;
    if (idHab == null) return;

    for (final l in luces) {
      l.encendida = encendida;
    }
    luces.refresh();

    final query = await _firestore
        .collection(nombreColeccion)
        .where('idHabitacion', isEqualTo: idHab)
        .get();

    final batch = _firestore.batch();
    for (final doc in query.docs) {
      batch.update(doc.reference, {'encendida': encendida});
    }
    await batch.commit();
  }

  Stream<LucesProgreso> progresoGlobalUsuario() {
    try {
      if (habitacionesController.habitacionesList.isEmpty) {
        return Stream.value(const LucesProgreso(total: 0, encendidas: 0));
      }

      final habitacionIds = habitacionesController.habitacionesList
          .map((h) => h.id)
          .where((id) => id.isNotEmpty)
          .toList();

      if (habitacionIds.isEmpty) {
        return Stream.value(const LucesProgreso(total: 0, encendidas: 0));
      }

      return _firestore
          .collection(nombreColeccion)
          .where('vinculada', isEqualTo: true)
          .where('idHabitacion', whereIn: habitacionIds)
          .snapshots()
          .map((qs) {
            final total = qs.docs.length;
            final encendidas = qs.docs
                .where((d) => (d.data()['encendida'] ?? false) == true)
                .length;

            return LucesProgreso(total: total, encendidas: encendidas);
          });
    } catch (e) {
      error.value = 'Error al obtener progreso global: $e';
      return Stream.value(const LucesProgreso(total: 0, encendidas: 0));
    }
  }

  Stream<LucesProgreso> progresoPorHabitacionStream(String idHabitacion) {
    if (idHabitacion.isEmpty) {
      return Stream.value(const LucesProgreso(total: 0, encendidas: 0));
    }

    return _firestore
        .collection(nombreColeccion)
        .where('idHabitacion', isEqualTo: idHabitacion)
        .snapshots()
        .map((qs) {
          final total = qs.docs.length;
          final encendidas = qs.docs
              .where((d) => (d.data()['encendida'] ?? false) == true)
              .length;

          return LucesProgreso(total: total, encendidas: encendidas);
        });
  }

  Future<void> _actualizarLuz(String luzId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(nombreColeccion).doc(luzId).update(data);
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Luces', 'No se pudo actualizar la luz: $e');
    }
  }

  void _setLocal(String luzId, void Function(Luces l) set) {
    final idx = luces.indexWhere((l) => l.id == luzId);
    if (idx == -1) return;
    set(luces[idx]);
    luces.refresh();
  }

  void _cancelAllDebouncers() {
    for (final t in _debouncers.values) {
      t.cancel();
    }
    _debouncers.clear();
  }
}
