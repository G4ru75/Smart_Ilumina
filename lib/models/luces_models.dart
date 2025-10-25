import 'package:flutter/material.dart';
import 'package:smart_ilumina/models/Horarios_models.dart';
import 'package:smart_ilumina/models/ciclos_models.dart';

class Luces {
  String id;
  String nombre;
  bool encendida;
  double intensidad;
  Color color;
  String idHabitacion;
  bool vinculada;
  final List<Horarios> horarios;
  final Ciclos? ciclos;

  Luces({
    String? id,
    required this.nombre,
    this.encendida = false,
    this.intensidad = 0.0,
    this.color = Colors.white,
    this.idHabitacion = '',
    this.vinculada = false,
    this.horarios = const [],
    this.ciclos,
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
      'horarios': horarios.map((h) => h.toMap()).toList(),
      'ciclos': ciclos?.toMap(),
    };
  }

  factory Luces.fromMap(Map<String, dynamic> map) {
    //Parcear horarios
    List<Horarios> horariosList = [];
    if (map['horarios'] != null && map['horarios'] is List) {
      horariosList = (map['horarios'] as List)
          .map((h) => Horarios.fromMap(h as Map<String, dynamic>))
          .toList();
    }

    //Parcear ciclos
    Ciclos? ciclosData;
    if (map['ciclos'] != null && map['ciclos'] is Map) {
      ciclosData = Ciclos.fromMap(map['ciclos'] as Map<String, dynamic>);
    }

    return Luces(
      id: map['id'] ?? UniqueKey().toString(),
      nombre: map['nombre'] ?? '',
      encendida: map['encendida'] ?? false,
      intensidad: (map['intensidad'] ?? 0.5).toDouble(),
      color: Color(map['color'] ?? Colors.white.value),
      idHabitacion: map['idHabitacion'] ?? '',
      vinculada: map['vinculada'] ?? false,
      horarios: horariosList,
      ciclos: ciclosData,
    );
  }
}
