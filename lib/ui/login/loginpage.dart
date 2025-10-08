import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/usuarios_controller.dart';
import 'package:smart_ilumina/ui/widgets/textos.dart';
import 'package:smart_ilumina/ui/login/registerpage.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final UsuariosController usuariosController = Get.find();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtContrasena = TextEditingController();

  String Validacion() {
    if (txtEmail.text.isEmpty) {
      return 'El correo electrónico no puede estar vacío';
    }

    if (txtContrasena.text.isEmpty) {
      return 'La contraseña no puede estar vacío';
    }

    if (txtEmail.text.isEmpty && txtContrasena.text.isEmpty) {
      return 'Debe de llenar todos los campos';
    }

    if (!txtEmail.text.contains('@') || !txtEmail.text.contains('.')) {
      return 'El correo electrónico no es válido';
    }

    if (txtContrasena.text.length < 5 ||
        txtContrasena.text.length > 20 ||
        txtContrasena.text.isEmpty) {
      return 'La contraseña debe tener entre 5 y 20 caracteres';
    }

    return 'OK';
  }

  void errorRegistro(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(Icons.error, color: Colors.red, size: 30),
          title: Text('Error de autenticación'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void alertaRegistroExitoso() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Inicio Exitoso'),
        content: Text('Bienvenido al sistema.'),
        icon: Icon(Icons.check_circle, color: Colors.green, size: 30),
        actions: [
          TextButton(
            onPressed: () {
              Get.offAllNamed('/home');
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: viewInsets),
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      Center(
                        child: Column(
                          children: [
                            TextoSuperior(texto: 'Smart💡ilumina'),
                            const SizedBox(height: 1),
                            const Icon(
                              Icons.lightbulb_outline,
                              size: 200,
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA9AED4),
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(100),
                            topRight: Radius.circular(100),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 16,
                              offset: Offset(0, -8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 42,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: TextoSuperior(texto: 'Login')),
                            const SizedBox(height: 24),
                            TextoField(
                              contrasena: false,
                              controlador: txtEmail,
                              titulo: 'Email',
                              textoSobre: 'Ingrese su correo electrónico',
                            ),
                            const SizedBox(height: 10),
                            TextoField(
                              contrasena: true,
                              controlador: txtContrasena,
                              titulo: 'Contraseña',
                              textoSobre: 'Ingrese su contraseña',
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.06,
                            ),
                            Center(
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 8,
                                    shadowColor: Colors.blueAccent,
                                  ),
                                  onPressed: () async {
                                    String validacion = Validacion();
                                    if (validacion != 'OK') {
                                      errorRegistro(context, validacion);
                                      return;
                                    }
                                    final ok = await usuariosController
                                        .loginUsuario(
                                          txtEmail.text.trim(),
                                          txtContrasena.text.trim(),
                                        );
                                    if (!mounted)
                                      return; // Evita usar context si se desmontó
                                    if (ok) {
                                      Get.offAllNamed('/home');
                                      txtContrasena.clear();
                                      txtEmail.clear();
                                    } else {
                                      errorRegistro(
                                        context,
                                        'Usuario o contraseña incorrecta',
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 20,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder:
                                          (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                          ) => Registerpage(),
                                      transitionsBuilder:
                                          (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                            child,
                                          ) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            );
                                          },
                                    ),
                                  );
                                },
                                child: TextosPequenos(texto: 'Registrarse'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
