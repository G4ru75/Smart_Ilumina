import 'package:flutter/material.dart';

class Luces {
  String nombre;
  bool encendida;
  double intensidad;
  Color color;

  Luces({
    required this.nombre,
    this.encendida = false,
    this.intensidad = 0.0,
    this.color = Colors.white,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'encendida': encendida,
      'intensidad': intensidad,
      'color': color.value,
    };
  }

  factory Luces.fromMap(Map<String, dynamic> map) {
    return Luces(
      nombre: map['nombre'] ?? '',
      encendida: map['encendida'] ?? false,
      intensidad: (map['intensidad'] ?? 0.5).toDouble(),
      color: Color(map['color'] ?? const Color(0xFFFFFFFF).value),
    );
  }
}
