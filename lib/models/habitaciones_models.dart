import 'package:smart_ilumina/models/luces_models.dart';
import 'package:flutter/material.dart';

class Habitaciones {
  String id;
  String idUsuario;
  String nombre;
  IconData icon;
  Color color;
  List<Luces> luces;
  String? valor;
  double? progreso;

  Habitaciones({
    String? id,
    required this.idUsuario,
    required this.nombre,
    required this.icon,
    required this.color,
    required this.luces,
    this.valor,
    this.progreso,
  }) : id = id ?? UniqueKey().toString();

  //Calcula el progreso dependiendo de las luces que hay y las que hay encendidas
  void actualizarProgreso() {
    final int total = luces.length;
    final int encendidas = luces.where((luces) => luces.encendida).length;
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
      'luces': luces
          .map((luz) => luz.toMap())
          .toList(), // Convertir cada luz a un mapa
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
      luces: (data['luces'] as List? ?? [])
          .map((luzMap) => Luces.fromMap(luzMap))
          .toList(),
      valor: data['valor'],
      progreso: (data['progreso'] ?? 0.0).toDouble(),
    );
    habitacion.actualizarProgreso();
    return habitacion;
  }
}
