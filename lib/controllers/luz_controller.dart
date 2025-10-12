import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/models/luces_models.dart';
import 'package:smart_ilumina/utils/lucesProgreso.dart';

class LucesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String nombreColeccion = 'luces';

  // Estados
  final RxList<Luces> luces = <Luces>[].obs;
  final RxBool loading = false.obs;
  final RxnString error = RxnString();
  final RxnString habitacionActualId = RxnString();

  // Streams y timers
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  final Map<String, Timer> _debouncers = {}; // por luzId para intensidad
  Timer? _scheduler; // verificador de hora encendido/apagado

  @override
  void onClose() {
    _cancelStream();
    _stopScheduler();
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
      }
    } catch (e) {
      error.value = e.toString();
      rethrow;
    }
  }

  // Escuchar luces por idHabitacion
  Future<void> escucharLucesDeHabitacion(String idHabitacion) async {
    await _cancelStream();
    habitacionActualId.value = idHabitacion;

    loading.value = true;
    _sub = _firestore
        .collection(nombreColeccion)
        .where('idHabitacion', isEqualTo: idHabitacion)
        .snapshots()
        .listen(
          (snap) {
            final lista = snap.docs
                .where((d) => d.exists && d.data().isNotEmpty)
                .map((d) => Luces.fromMap(d.data()))
                .toList();

            luces.assignAll(lista);
            loading.value = false;

            // (Re)inicia el scheduler cuando hay datos
            _startScheduler();
          },
          onError: (e) {
            error.value = e.toString();
            loading.value = false;
          },
        );
  }

  Future<void> _cancelStream() async {
    await _sub?.cancel();
    _sub = null;
    luces.clear();
  }

  // siguen las funciones de las modificaciones de las luces

  Future<void> cambiarEstadoLuz(String luzId, bool encendida) async {
    // Optimista
    _setLocal(luzId, (l) => l.encendida = encendida);
    await _updateLuz(luzId, {'encendida': encendida});
  }

  Future<void> cambiarColor(String luzId, Color color) async {
    _setLocal(luzId, (l) => l.color = color);
    await _updateLuz(luzId, {'color': color.value});
  }

  void cambiarIntensidadDebounced(String luzId, double valor) {
    // Actualiza local de inmediato
    _setLocal(luzId, (l) => l.intensidad = valor.clamp(0.0, 1.0));

    // Debounce para escribir en Firestore
    _debouncers[luzId]?.cancel();
    _debouncers[luzId] = Timer(const Duration(milliseconds: 180), () async {
      await _updateLuz(luzId, {'intensidad': valor.clamp(0.0, 1.0)});
      _debouncers.remove(luzId);
    });
  }

  Future<void> cambiarHoras(
    String luzId, {
    TimeOfDay? horaEncendido,
    TimeOfDay? horaApagado,
  }) async {
    final data = <String, dynamic>{};
    if (horaEncendido != null) {
      data['horaEncendido'] = {
        'hour': horaEncendido.hour,
        'minute': horaEncendido.minute,
      };
      _setLocal(luzId, (l) => l.horaEncendido = horaEncendido);
    }
    if (horaApagado != null) {
      data['horaApagado'] = {
        'hour': horaApagado.hour,
        'minute': horaApagado.minute,
      };
      _setLocal(luzId, (l) => l.horaApagado = horaApagado);
    }
    if (data.isNotEmpty) {
      await _updateLuz(luzId, data);
    }
  }

  // Encender o apagar todas en la habitación actual
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

  //Para la hora, revisa la hora y si debe encender una luz o no

  void _startScheduler() {
    _scheduler?.cancel();
    // No dispara si no hay luces escuchándose
    if (habitacionActualId.value == null) return;

    _scheduler = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _applySchedulesTick(),
    );
    _applySchedulesTick(); // primera corrida inmediata
  }

  void _stopScheduler() {
    _scheduler?.cancel();
    _scheduler = null;
  }

  Future<void> _applySchedulesTick() async {
    if (luces.isEmpty) return;
    final now = DateTime.now();

    // Determina cambios y los aplica en lote
    final List<MapEntry<String, bool>> cambios = [];

    for (final l in luces) {
      final encendido = l.horaEncendido;
      final apagado = l.horaApagado;
      if (encendido == null || apagado == null) continue;

      final shouldBeOn = _isNowBetween(encendido, apagado, now);
      if (l.encendida != shouldBeOn) {
        // Actualiza local y programa update remoto
        l.encendida = shouldBeOn;
        cambios.add(MapEntry(l.id, shouldBeOn));
      }
    }

    if (cambios.isNotEmpty) {
      luces.refresh();
      final batch = _firestore.batch();
      for (final c in cambios) {
        final ref = _firestore.collection(nombreColeccion).doc(c.key);
        batch.update(ref, {'encendida': c.value});
      }
      await batch.commit();
    }
  }

  // Dentro de [on, off) con soporte a cruce de medianoche
  bool _isNowBetween(TimeOfDay on, TimeOfDay off, DateTime now) {
    final start = DateTime(now.year, now.month, now.day, on.hour, on.minute);
    final end = DateTime(now.year, now.month, now.day, off.hour, off.minute);

    if (!end.isBefore(start)) {
      final afterStart = now.isAfter(start) || now.isAtSameMomentAs(start);
      final beforeEnd = now.isBefore(end);
      return afterStart && beforeEnd;
    } else {
      final afterStart = now.isAfter(start) || now.isAtSameMomentAs(start);
      final beforeEnd = now.isBefore(end);
      return afterStart || beforeEnd;
    }
  }

  Future<void> _updateLuz(String luzId, Map<String, dynamic> data) async {
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

  int get totalLuces => luces.length;
  int get lucesEncendidas => luces.where((l) => l.encendida).length;
  String get progreso =>
      totalLuces == 0 ? '0/0' : '$lucesEncendidas/$totalLuces';
}
