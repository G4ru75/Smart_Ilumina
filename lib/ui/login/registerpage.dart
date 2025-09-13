import 'package:flutter/material.dart';
import 'package:smart_ilumina/ui/widgets/textos.dart';
import 'package:smart_ilumina/ui/login/loginpage.dart';

class Registerpage extends StatefulWidget {
  final List<Usuario>? usuarios;
  Registerpage({Key? key, required this.usuarios}) : super(key: key);

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  final TextEditingController txtUsuario = TextEditingController();
  final TextEditingController txtContrasena = TextEditingController();

  String Validacion() {
    if (txtUsuario.text.isEmpty || txtContrasena.text.isEmpty) {
      return 'Por favor llene todos los campos';
    }
    for (var usuario in widget.usuarios!) {
      if (usuario.nombre == txtUsuario.text) {
        return 'El usuario ya existe, por favor elija otro nombre';
      }
    }
    return 'OK';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Registro')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.app_registration, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Pagina de registro',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 60),
            TextoSuperior(texto: 'Nombre'),
            TextoField(
              contrasena: false,
              titulo: 'Nombre',
              controlador: txtUsuario,
              textoSobre: 'Ingrese su nombre de usuario',
            ),
            TextoField(
              contrasena: true,
              titulo: 'Contraseña',
              controlador: txtContrasena,
              textoSobre: 'Ingrese una contraseña segura',
            ),

            ElevatedButton(
              onPressed: () {
                if (Validacion() == 'OK') {
                  widget.usuarios?.add(
                    Usuario(
                      nombre: txtUsuario.text,
                      contrasena: txtContrasena.text,
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LoginPage(usuarios: widget.usuarios),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        icon: Icon(Icons.error, color: Colors.red, size: 30),
                        title: Text('Error'),
                        content: Text(Validacion()),
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
              },
              child: Text('Registrar usuario'),
            ),
          ],
        ),
      ),
    );
  }
}

class Usuario {
  String nombre;
  String contrasena;

  Usuario({required this.nombre, required this.contrasena});
}
