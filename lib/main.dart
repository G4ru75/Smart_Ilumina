import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/habitaciones_controller.dart';
import 'package:smart_ilumina/controllers/usuarios_controller.dart';
import 'ui/app.dart';

void main() {
  Get.put(UsuariosController());
  Get.put(HabitacionesController());
  runApp(const MyApp());
}
