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
  Timer? _scheduler; // verificador de hora encendido/apagado

  final Map<String, DateTime> _ultimoHorarioAplicado = {};

  @override
  void onInit() {
    _startScheduler();
    super.onInit();
  }

  @override
  void onClose() {
    _cancelStream();
    _stopScheduler();
    _cancelAllDebouncers();
    _ultimoHorarioAplicado.clear();
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

  // siguen las funciones de las modificaciones de las luces

  Future<void> cambiarEstadoLuz(String luzId, bool encendida) async {
    _setLocal(luzId, (l) => l.encendida = encendida);
    await _ActualizarLuz(luzId, {'encendida': encendida});
  }

  Future<void> cambiarColor(String luzId, Color color) async {
    _setLocal(luzId, (l) => l.color = color);
    await _ActualizarLuz(luzId, {'color': color.value});
  }

  void cambiarIntensidadDebounced(String luzId, double valor) {
    // Actualiza local de inmediato
    _setLocal(luzId, (l) => l.intensidad = valor.clamp(0.0, 1.0));

    // Debounce para escribir en Firestore
    _debouncers[luzId]?.cancel();
    _debouncers[luzId] = Timer(const Duration(milliseconds: 180), () async {
      await _ActualizarLuz(luzId, {'intensidad': valor.clamp(0.0, 1.0)});
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

  Future<void> cambiarHoras(
    String luzId, {
    TimeOfDay? horaEncendido,
    TimeOfDay? horaApagado,
  }) async {
    final data = <String, dynamic>{};
    if (horaEncendido != null) {
      data['horaEncendido'] = {
        'hora': horaEncendido.hour,
        'minuto': horaEncendido.minute,
      };
      _setLocal(luzId, (l) => l.horaEncendido = horaEncendido);
    }
    if (horaApagado != null) {
      data['horaApagado'] = {
        'hora': horaApagado.hour,
        'minuto': horaApagado.minute,
      };
      _setLocal(luzId, (l) => l.horaApagado = horaApagado);
    }
    if (data.isNotEmpty) {
      await _ActualizarLuz(luzId, data);
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

    _scheduler = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _applySchedulesTick(),
    );
    _applySchedulesTick(); // primera corrida inmediata
  }

  void _stopScheduler() {
    _scheduler?.cancel();
    _scheduler = null;
  }

  Future<void> _applySchedulesTick() async {
    try {
      final habitacionIds = habitacionesController.habitacionesList
          .map((h) => h.id)
          .where((id) => id.isNotEmpty)
          .toList();

      if (habitacionIds.isEmpty) return;

      final querySnapshot = await _firestore
          .collection(nombreColeccion)
          .where('idHabitacion', whereIn: habitacionIds)
          .where('vinculada', isEqualTo: true)
          .get();

      if (querySnapshot.docs.isEmpty) return;

      final now = DateTime.now();
      final horaActual = TimeOfDay.fromDateTime(now);

      final batch = _firestore.batch();
      bool hayCambios = false;

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final luz = Luces.fromMap(data);
        bool? nuevoEstado;

        final encendido = luz.horaEncendido;
        final apagado = luz.horaApagado;

        if (encendido == null || apagado == null) continue;

        final horaEncender = _horaExacta(horaActual, encendido);
        final horaApagar = _horaExacta(horaActual, apagado);

        final ultimaAplicacion =
            _ultimoHorarioAplicado[luz
                .id]; //Evita que se aplique el mismo horario más de una vez en el mismo minuto
        if (ultimaAplicacion != null) {
          final mismoMinuto =
              ultimaAplicacion.year == now.year &&
              ultimaAplicacion.month == now.month &&
              ultimaAplicacion.day == now.day &&
              ultimaAplicacion.hour == now.hour &&
              ultimaAplicacion.minute == now.minute;

          if (mismoMinuto) continue; // Ya se aplicó en este minuto, skip
        }

        if (horaEncender) {
          nuevoEstado = true;
        } else if (horaApagar) {
          nuevoEstado = false;
        }

        if (nuevoEstado != null) {
          batch.update(doc.reference, {'encendida': nuevoEstado});
          _ultimoHorarioAplicado[luz.id] = now;
          hayCambios = true;

          _setLocal(luz.id, (l) => l.encendida = nuevoEstado!);
        }
      }

      if (hayCambios) {
        await batch.commit();
      }
    } catch (e, stackTrace) {
      print('Error en el scheduler: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // Con soporte a cruce de medianoche
  bool _horaExacta(TimeOfDay actual, TimeOfDay programada) {
    final actualMinutos = actual.hour * 60 + actual.minute;
    final programadaMinutos = programada.hour * 60 + programada.minute;

    return actualMinutos == programadaMinutos;
  }

  Future<void> _ActualizarLuz(String luzId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(nombreColeccion).doc(luzId).update(data);
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Luces', 'No se pudo actualizar la luz: $e');
    }
  }

  /// Este es para la cantidad de luces del usuario encendidas encima del total de luces del usuario
  /// tambien se ayuda del utils de lucesProgreso
  Stream<LucesProgreso> progresoGlobalUsuario() {
    try {
      // Si no hay habitaciones, devuelve 0/0
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

      // Escucha todas las luces vinculadas del usuario
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

  // Este se ayuda del utils de lucesProgreso para dar el progreso de las luces encendidas por habitacion
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

  // ...existing code...

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
