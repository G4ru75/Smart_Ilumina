import 'package:get/get.dart';
import 'package:smart_ilumina/models/usuarios_models.dart';

class UsuariosController extends GetxController {
  var usuariosList = <Usuario>[
    Usuario(
      nombre: 'Home',
      fechaNacimiento: DateTime(2000, 1, 1),
      email: 'home@example.com',
      contrasena: '12345',
    ),
  ];

  void agregarUsuario(
    String nombre,
    DateTime fechaNacimiento,
    String email,
    String contrasena,
  ) {
    usuariosList.add(
      Usuario(
        nombre: nombre,
        fechaNacimiento: fechaNacimiento,
        email: email,
        contrasena: contrasena,
      ),
    );
  }

  bool verificarUsuario(String email, String contrasena) {
    for (var usuario in usuariosList) {
      if (usuario.email == email && usuario.contrasena == contrasena) {
        return true;
      }
    }
    return false;
  }
}
