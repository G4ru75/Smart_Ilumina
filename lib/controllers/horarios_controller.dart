import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/models/Horarios_models.dart';
import 'package:smart_ilumina/models/luces_models.dart';

class HorariosController extends GetxController {
  final String nombreColeccion = 'luces';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Luces> luces = <Luces>[].obs;

  Future<void> agregarHorario(String luzId, Horarios horario) async {
    try {
      final luz = luces.firstWhereOrNull((l) => l.id == luzId);

      if (luz == null) return;

      final nuevosHorarios = [...luz.horarios, horario];

      await _firestore.collection(nombreColeccion).doc(luzId).update({
        'horarios': nuevosHorarios.map((h) => h.toMap()).toList(),
      });

      Get.snackbar(
        'Horario agregado',
        'Horario agregado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Ops, ha ocurrido un error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  //Sirve ara activar o desactivar un horario
  Future<void> toggleHorarios(
    String luzId,
    String horarioId,
    bool activo,
  ) async {
    try {
      final luz = luces.firstWhereOrNull((l) => l.id == luzId);
      if (luz == null) return;

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
    } catch (e) {
      Get.snackbar(
        'Error',
        'Ops, ha ocurrido un error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
