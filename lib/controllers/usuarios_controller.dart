

import 'package:smart_ilumina/models/usuarios_models.dart';

class usuarios_controller extends GextController {
  var UsuariosList = <Usuario>[]; 

  void agregarUsuario(String nombre, DateTime fechaNacimiento, String email, String contrasena,)
  {
    UsuariosList.add(Usuario(nombre: nombre, fechaNacimiento: fechaNacimiento, email: email, contrasena: contrasena))
  }

  bool verificarUsuario(String email, String contrasena){
    for(usuario in UsuariosList){
      if(usuario.email == email && usuario.contrasena == contrasena){
        return true;
      }
    }
    return false; 
  }


}
