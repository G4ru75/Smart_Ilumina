import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/usuarios_controller.dart';
import 'package:smart_ilumina/ui/widgets/textos.dart';
import 'package:smart_ilumina/ui/home/homepage.dart';
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

    if (usuariosController.verificarUsuario(
      txtEmail.text,
      txtContrasena.text,
    )) {
      return 'OK';
    } else {
      return 'Usuario o contraseña incorrecta';
    }

    return 'Ha ocurrido un error';
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
              Navigator.of(context).pop();
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      HomePage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                ),
              ); // Solo cerrar el diálogo
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 130),
            // Encabezado con texto y bombilla
            Center(
              child: Column(
                children: [
                  TextoSuperior(texto: 'Smart💡ilumina'),
                  SizedBox(height: 10),
                  Icon(
                    Icons.lightbulb_outline,
                    size: 204,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
            Spacer(),
            // Tarjeta del login
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFA9AED4),
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                  topRight: Radius.circular(100),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: TextoSuperior(texto: 'Login')),
                  SizedBox(height: 24),

                  SizedBox(height: 4),
                  TextoField(
                    contrasena: false,
                    controlador: txtEmail,
                    titulo: 'Email',
                    textoSobre: 'Ingrese su correo electrónico',
                  ),
                  SizedBox(height: 18),
                  SizedBox(height: 4),
                  TextoField(
                    contrasena: true,
                    controlador: txtContrasena,
                    titulo: 'Contraseña',
                    textoSobre: 'Ingrese su contraseña',
                  ),
                  SizedBox(height: 32),
                  Center(
                    child: Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          shadowColor: Colors.blueAccent,
                        ),
                        onPressed: () {
                          String validacion = Validacion();
                          if (validacion != 'OK') {
                            errorRegistro(context, validacion);
                          } else {
                            alertaRegistroExitoso();
                            txtContrasena.clear();
                            txtEmail.clear();
                          }
                        },
                        child: Text(
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
                  SizedBox(height: 15),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    Registerpage(),
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
    );
  }
}
