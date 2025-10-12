import 'package:flutter/material.dart';

class Habitaciones {
  String id;
  String idUsuario;
  String nombre;
  IconData icon;
  Color color;
  String? valor;
  double? progreso;

  Habitaciones({
    String? id,
    required this.idUsuario,
    required this.nombre,
    required this.icon,
    required this.color,
    this.valor,
    this.progreso,
  }) : id = id ?? UniqueKey().toString();

  //Calcula el progreso dependiendo de las luces que hay y las que hay encendidas
  void actualizarProgreso() {
    final int total = 0; // No hay luces
    final int encendidas = 0; // No hay luces encendidas
    valor = total == 0 ? '0/0' : '$encendidas/$total';
    progreso = total == 0 ? 0.0 : encendidas / total;
  }

  //Para enviarla bien a firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idUsuario': idUsuario,
      'nombre': nombre,
      'icon': icon.codePoint, // Guardar el codePoint del icono
      'color': color.value,
      'valor': valor,
      'progreso': progreso,
    };
  }

  factory Habitaciones.fromFirebase(Map<String, dynamic> data) {
    final habitacion = Habitaciones(
      id: data['id'] ?? UniqueKey().toString(),
      idUsuario: data['idUsuario'] ?? '',
      nombre: data['nombre'] ?? '',
      icon: IconData(
        data['icon'] ?? Icons.home.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      color: Color(data['color'] ?? Colors.blue.value),
      valor: data['valor'],
      progreso: (data['progreso'] ?? 0.0).toDouble(),
    );
    habitacion.actualizarProgreso();
    return habitacion;
  }
}
