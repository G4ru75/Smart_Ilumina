import 'package:flutter/material.dart';

class Luces {
  String id;
  String nombre;
  bool encendida;
  double intensidad;
  Color color;
  String idHabitacion;
  bool vinculada;
  TimeOfDay? horaEncendido;
  TimeOfDay? horaApagado;

  Luces({
    String? id,
    required this.nombre,
    this.encendida = false,
    this.intensidad = 0.0,
    this.color = Colors.white,
    this.idHabitacion = '',
    this.vinculada = false,
    this.horaEncendido,
    this.horaApagado,
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
      'horaEncendido': horaEncendido != null
          ? {'hora': horaEncendido!.hour, 'minuto': horaEncendido!.minute}
          : null,
      'horaApagado': horaApagado != null
          ? {'hora': horaApagado!.hour, 'minuto': horaApagado!.minute}
          : null,
    };
  }

  factory Luces.fromMap(Map<String, dynamic> map) {
    TimeOfDay? _parseTime(dynamic tiempo) {
      if (tiempo == null) return null;
      if (tiempo is Map) {
        final hora = tiempo['hora'] as int?;
        final minuto = tiempo['minuto'] as int?;
        if (hora != null && minuto != null) {
          return TimeOfDay(hour: hora, minute: minuto);
        }
      }
      if (tiempo is String) {
        final partes = tiempo.split(':');
        if (partes.length == 2) {
          final hora = int.tryParse(partes[0]);
          final minuto = int.tryParse(partes[1]);
          if (hora != null && minuto != null) {
            return TimeOfDay(hour: hora, minute: minuto);
          }
        }
      }
    }

    return Luces(
      id: map['id'] ?? UniqueKey().toString(),
      nombre: map['nombre'] ?? '',
      encendida: map['encendida'] ?? false,
      intensidad: (map['intensidad'] ?? 0.5).toDouble(),
      color: Color(map['color'] ?? Colors.white.value),
      idHabitacion: map['idHabitacion'] ?? '',
      vinculada: map['vinculada'] ?? false,
      horaEncendido: _parseTime(map['horaEncendido']),
      horaApagado: _parseTime(map['horaApagado']),
    );
  }
}
