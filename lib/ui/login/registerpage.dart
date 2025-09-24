import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/usuarios_controller.dart';
import 'package:smart_ilumina/ui/widgets/textos.dart';
import 'package:smart_ilumina/ui/login/loginpage.dart';

class Registerpage extends StatefulWidget {
  Registerpage({Key? key}) : super(key: key);

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  final UsuariosController usuariosControler = Get.find();
  final TextEditingController txtNombre = TextEditingController();
  final TextEditingController txtFechaNacimiento = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtContrasena = TextEditingController();

  String Validacion() {
    if (txtEmail.text.isEmpty ||
        txtNombre.text.isEmpty ||
        txtFechaNacimiento.text.isEmpty) {
      return 'Por favor llene todos los campos';
    }

    if (txtNombre.text.length < 3 ||
        txtNombre.text.length > 30 ||
        txtNombre.text.isEmpty) {
      return 'El nombre debe tener entre 3 y 30 caracteres';
    }
    if (txtFechaNacimiento.text.length < 3 ||
        txtFechaNacimiento.text.length > 30 ||
        txtFechaNacimiento.text.isEmpty) {
      return 'La fecha de nacimiento no es válida';
    }
    if (!txtEmail.text.contains('@') || !txtEmail.text.contains('.')) {
      return 'El correo electrónico no es válido';
    }
    if (txtContrasena.text.length < 5 ||
        txtContrasena.text.length > 20 ||
        txtContrasena.text.isEmpty) {
      return 'La contraseña debe tener entre 5 y 20 caracteres';
    }

    for (var usuario in usuariosControler.usuariosList) {
      if (usuario.email == txtEmail.text) {
        return 'El usuario ya existe, por favor elija otro nombre';
      }
    }
    return 'OK';
  }

  void alertaRegistroExitoso() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registro Exitoso'),
        content: Text('El usuario ha sido registrado exitosamente.'),
        icon: Icon(Icons.check_circle, color: Colors.green, size: 30),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      LoginPage(),
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

  void alertaRegistroFallido(String resultado) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error de Registro'),
        content: Text(resultado),
        icon: Icon(Icons.error, color: Colors.red, size: 30),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar el diálogo
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 50),
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
                  Center(child: TextoSuperior(texto: 'Sign Up')),
                  SizedBox(height: 10),
                  TextoField(
                    contrasena: false,
                    controlador: txtNombre,
                    titulo: 'Nombre',
                    textoSobre: 'Ingrese su nombre',
                  ),
                  SizedBox(height: 10),
                  InputFecha(
                    controller: txtFechaNacimiento,
                    label: 'Fecha de Nacimiento',
                  ),
                  SizedBox(height: 10),
                  TextoField(
                    contrasena: false,
                    controlador: txtEmail,
                    titulo: 'Email',
                    textoSobre: 'Ingrese su correo electrónico',
                  ),
                  SizedBox(height: 10),
                  TextoField(
                    contrasena: true,
                    controlador: txtContrasena,
                    titulo: 'Contraseña',
                    textoSobre: 'Ingrese su contraseña',
                  ),
                  SizedBox(height: 40),
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
                          String resultado = Validacion();
                          if (resultado == 'OK') {
                            DateTime fechaNacimiento = DateTime.parse(
                              txtFechaNacimiento.text,
                            );
                            usuariosControler.agregarUsuario(
                              txtNombre.text.trim(),
                              fechaNacimiento,
                              txtEmail.text.trim(),
                              txtContrasena.text.trim(),
                            );
                            txtNombre.clear();
                            txtFechaNacimiento.clear();
                            txtEmail.clear();
                            txtContrasena.clear();
                            alertaRegistroExitoso();
                          } else {
                            alertaRegistroFallido(resultado);
                          }
                        },
                        child: Text(
                          'Sign Up',
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
                                    LoginPage(),
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
                      child: TextosPequenos(texto: 'Iniciar sesion'),
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
