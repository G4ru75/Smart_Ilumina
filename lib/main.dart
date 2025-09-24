import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/usuarios_controller.dart';
import 'ui/app.dart';

void main() {
  Get.put(UsuariosController());
  runApp(const MyApp());
}
