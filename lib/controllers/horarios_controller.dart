import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/luz_controller.dart';
import 'package:smart_ilumina/models/Horarios_models.dart';
import 'package:smart_ilumina/models/luces_models.dart';

class HorariosController extends GetxController {
  final String nombreColeccion = 'luces';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final lucesController = Get.find<LucesController>();
  RxList<Luces> get luces => lucesController.luces;

  Future<void> agregarHorario(String luzId, Horarios horario) async {
    try {
      final docSnapshot = await _firestore
          .collection(nombreColeccion)
          .doc(luzId)
          .get();

      if (!docSnapshot.exists) return;

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

      if (!docSnapshot.exists) return;

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

      await Future.delayed(Duration(seconds: 1));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Ops, ha ocurrido un error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> eliminarHorario(String luzId, String horarioId) async {
    try {
      final docSnapshot = await _firestore
          .collection(nombreColeccion)
          .doc(luzId)
          .get();

      if (!docSnapshot.exists) return;

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

  Future<void> editarHorario(String luzId, Horarios horario) async {
    try {
      final docSnapshot = await _firestore
          .collection(nombreColeccion)
          .doc(luzId)
          .get();

      if (!docSnapshot.exists) return;

      final luz = Luces.fromMap(docSnapshot.data()!);

      final nuevosHorarios = luz.horarios.map((h) {
        if (h.id == horario.id) {
          return horario;
        }
        return h;
      }).toList();

      await _firestore.collection(nombreColeccion).doc(luzId).update({
        'horarios': nuevosHorarios.map((h) => h.toMap()).toList(),
      });

      Get.snackbar(
        'Horario editado',
        'El horario ha sido editado correctamente',
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
}
