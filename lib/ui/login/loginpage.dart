import 'package:flutter/material.dart';
import 'package:smart_ilumina/ui/widgets/textos.dart';
import 'package:smart_ilumina/ui/home/homepage.dart';
import 'package:smart_ilumina/ui/login/registerpage.dart';

class LoginPage extends StatefulWidget {
  final List<Usuario> usuarios;
  LoginPage({Key? key, List<Usuario>? usuarios})
    : usuarios = (usuarios == null || usuarios.isEmpty)
          ? [
              Usuario(
                nombre: 'home',
                fechaNacimiento: DateTime(2000, 1, 1),
                email: 'home@example.com',
                contrasena: '12345',
              ),
            ]
          : usuarios!,
      super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

void Alerta(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        icon: Icon(Icons.error, color: Colors.red, size: 30),
        title: Text('Error'),
        content: Text(
          'Email o contraseña incorrectos verifique el usuario o cree uno nuevo por favor',
        ),
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

class _LoginPageState extends State<LoginPage> {
  final TextEditingController txtUsuario = TextEditingController();
  final TextEditingController txtContrasena = TextEditingController();

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
                    controlador: txtUsuario,
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
                          padding: EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          shadowColor: Colors.blueAccent,
                        ),
                        onPressed: () {
                          for (var usuario in widget.usuarios) {
                            if (usuario.nombre == txtUsuario.text &&
                                usuario.contrasena == txtContrasena.text) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                              return;
                            }
                          }
                          Alerta(context);
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
                                    Registerpage(usuarios: widget.usuarios),
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
