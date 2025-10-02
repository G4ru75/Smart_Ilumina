import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  String nombre;
  DateTime fechaNacimiento;
  String email;

  Usuario({
    required this.nombre,
    required this.fechaNacimiento,
    required this.email,
  });

  factory Usuario.fromMap(Map<String, dynamic> data) {
    return Usuario(
      nombre: data['nombre'] ?? '',
      fechaNacimiento:
          (data['fechaNacimiento'] as Timestamp?)?.toDate() ?? DateTime.now(),
      email: data['email'] ?? '',
    );
  }

  // Convierte la instancia de Usuario a un mapa para guardarlo en Firestore.
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'fechaNacimiento': fechaNacimiento,
      'email': email,
    };
  }
}
