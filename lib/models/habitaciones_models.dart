import 'package:smart_ilumina/models/luces_models.dart';
import 'package:flutter/material.dart';

class Habitaciones {
  String nombre;
  IconData icon;
  Color color;
  List<Luces> luces;
  String? valor;
  double? progreso;

  Habitaciones({
    required this.nombre,
    required this.icon,
    required this.color,
    required this.luces,
    this.valor,
    this.progreso,
  });

  //Calcula el progreso dependiendo de las luces que hay y las que hay encendidas
  void actualizarProgreso() {
    final int total = luces.length;
    final int encendidas = luces.where((luces) => luces.encendida).length;
    valor = total == 0 ? '0/0' : '$encendidas/$total';
    progreso = total == 0 ? 0.0 : encendidas / total;
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'icon': icon.codePoint, // Guardar el codePoint del icono
      'color': color.value,
      'luces': luces
          .map((luz) => luz.toMap())
          .toList(), // Convertir cada luz a un mapa
    };
  }

  factory Habitaciones.fromMap(Map<String, dynamic> map) {
    final habitacion = Habitaciones(
      nombre: map['nombre'] ?? '',
      icon: IconData(map['icon']) ?? Icons.room,
      color: Color(map['color']) ?? Colors.blue,
      luces: (map['luces'] as List? ?? [])
          .map((luzMap) => Luces.fromMap(luzMap))
          .toList(),
    );
    habitacion.actualizarProgreso();
    return habitacion;
  }
}
