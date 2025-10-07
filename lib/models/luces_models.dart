import 'package:flutter/material.dart';

class Luces {
  String id;
  String nombre;
  bool encendida;
  double intensidad;
  Color color;
  String idHabitacion;
  bool vinculada;

  Luces({
    String? id,
    required this.nombre,
    this.encendida = false,
    this.intensidad = 0.0,
    this.color = Colors.white,
    this.idHabitacion = '',
    this.vinculada = false,
  }) : id = id ?? UniqueKey().toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'encendida': encendida,
      'intensidad': intensidad,
      'color': color.value,
      'idHabitacion': idHabitacion,
      'vinculada': vinculada,
    };
  }

  factory Luces.fromMap(Map<String, dynamic> map) {
    return Luces(
      id: map['id'] ?? UniqueKey().toString(),
      nombre: map['nombre'] ?? '',
      encendida: map['encendida'] ?? false,
      intensidad: (map['intensidad'] ?? 0.5).toDouble(),
      color: Color(map['color'] ?? Colors.white.value),
      idHabitacion: map['idHabitacion'] ?? '',
      vinculada: map['vinculada'] ?? false,
    );
  }
}
