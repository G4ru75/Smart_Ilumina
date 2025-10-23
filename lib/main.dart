import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import 'package:smart_ilumina/controllers/habitaciones_controller.dart';
import 'package:smart_ilumina/controllers/horarios_controller.dart';
import 'package:smart_ilumina/controllers/luz_controller.dart';
import 'package:smart_ilumina/controllers/usuarios_controller.dart';
import 'package:smart_ilumina/firebase_options.dart';
import 'package:smart_ilumina/utils/auth_storage.dart';
import 'ui/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar GetStorage (solo una vez)
  await GetStorage.init();

  // Inicializar AuthStorage
  final authStorage = AuthStorage();
  await authStorage.init();

  // Registrar controladores
  final usuariosController = Get.put(UsuariosController());
  Get.put(HabitacionesController());
  Get.put(LucesController());

  // Verificar si hay sesión guardada y hacer auto-login
  bool hasActiveSession = false;
  if (authStorage.hasSession()) {
    hasActiveSession = await usuariosController.autoLogin();
  }

  // Configurar UI del sistema
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  ); // hace que desaparezca la barra de accion de los moviles

  // Ejecutar app con la ruta inicial adecuada
  runApp(MyApp(initialRoute: hasActiveSession ? '/home' : '/login'));
}
