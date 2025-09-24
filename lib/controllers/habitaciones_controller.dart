import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/models/habitaciones_models.dart';
import '../models/luces_models.dart';

class HabitacionesController extends GetxController {
  var habitacionesList = <Habitaciones>[].obs;

  @override
  void onInit() {
    super.onInit();
    _cargarHabitacionesIniciales();
  }

  void _cargarHabitacionesIniciales() {
    habitacionesList.clear();
    habitacionesList.addAll([
      Habitaciones(
        nombre: 'Sala',
        icon: Icons.weekend,
        color: Colors.blue,
        luces: [
          Luces(
            nombre: 'Luz 1',
            encendida: true,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 2',
            encendida: true,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 3',
            encendida: true,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 4',
            encendida: true,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 5',
            encendida: false,
            intensidad: 0.5,
            color: Colors.white,
          ),
        ],
      ),
      Habitaciones(
        nombre: 'Dormitorio',
        icon: Icons.bed,
        color: Colors.blue,
        luces: [
          Luces(
            nombre: 'Luz 1',
            encendida: true,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 2',
            encendida: true,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 3',
            encendida: true,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 4',
            encendida: true,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 5',
            encendida: false,
            intensidad: 0.5,
            color: Colors.white,
          ),
        ],
      ),
      Habitaciones(
        nombre: 'Baño',
        icon: Icons.bathtub,
        color: Colors.blue,
        luces: [
          Luces(
            nombre: 'Luz 1',
            encendida: false,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 2',
            encendida: false,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 3',
            encendida: false,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 4',
            encendida: false,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 5',
            encendida: false,
            intensidad: 0.5,
            color: Colors.white,
          ),
        ],
      ),
      Habitaciones(
        nombre: 'Terraza',
        icon: Icons.deck,
        color: Colors.green,
        luces: [
          Luces(
            nombre: 'Luz 1',
            encendida: true,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 2',
            encendida: true,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 3',
            encendida: true,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 4',
            encendida: true,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 5',
            encendida: false,
            intensidad: 0.5,
            color: Colors.white,
          ),
        ],
      ),
      Habitaciones(
        nombre: 'Cocina',
        icon: Icons.kitchen,
        color: Colors.black54,
        luces: [
          Luces(
            nombre: 'Luz 1',
            encendida: false,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 2',
            encendida: false,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 3',
            encendida: false,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 4',
            encendida: false,
            intensidad: 0.5,
            color: Colors.white,
          ),
          Luces(
            nombre: 'Luz 5',
            encendida: false,
            intensidad: 0.5,
            color: Colors.white,
          ),
        ],
      ),
    ]);

    for (var habitacion in habitacionesList) {
      habitacion.actualizarProgreso();
    }

    habitacionesList.refresh();
  }

  void agregarHabitacion(String nombre, {IconData? icon, Color? color}) {
    final nuevaHabitacion = Habitaciones(
      nombre: nombre,
      icon: icon ?? Icons.room,
      color: color ?? Colors.purple,
      luces: [
        Luces(
          nombre: 'Nueva luz',
          encendida: false,
          intensidad: 0.5,
          color: Colors.white,
        ),
      ],
    );
    nuevaHabitacion.actualizarProgreso();
    habitacionesList.add(nuevaHabitacion);
  }

  void cambiarEstadoLuz(int habitacionIndex, int luzIndex, bool encendida) {
    if (habitacionIndex >= 0 && habitacionIndex < habitacionesList.length) {
      final habitacion = habitacionesList[habitacionIndex];

      if (luzIndex >= 0 && luzIndex < habitacion.luces.length) {
        habitacion.luces[luzIndex].encendida = encendida;
        habitacion.actualizarProgreso();
        habitacionesList.refresh();
      }
    }
  }

  Habitaciones? obtenerHabitacion(int index) {
    if (index >= 0 && index < habitacionesList.length) {
      return habitacionesList[index];
    }
    return null;
  }

  void cambiarEstadoTodasLuces(int habitacionIndex, bool encendida) {
    if (habitacionIndex >= 0 && habitacionIndex < habitacionesList.length) {
      final habitacion = habitacionesList[habitacionIndex];

      // Cambiar el estado de todas las luces
      for (var luz in habitacion.luces) {
        luz.encendida = encendida;
      }

      habitacion.actualizarProgreso();
      habitacionesList.refresh();
    }
  }

  void configurarLuz(
    int habitacionIndex,
    int luzIndex, {
    bool? encendida,
    double? intensidad,
    Color? color,
  }) {
    if (habitacionIndex >= 0 && habitacionIndex < habitacionesList.length) {
      final habitacion = habitacionesList[habitacionIndex];

      if (luzIndex >= 0 && luzIndex < habitacion.luces.length) {
        final luz = habitacion.luces[luzIndex];
        if (encendida != null) {
          luz.encendida = encendida;
        }
        if (intensidad != null) {
          luz.intensidad = intensidad;
        }
        if (color != null) {
          luz.color = color;
        }

        habitacion.actualizarProgreso();
        habitacionesList.refresh();
      }
    }
  }

  String cantidadLuces() {
    final lista = habitacionesList;
    if (lista.isEmpty) {
      return '0/0';
    }
    final totalLuces = lista.fold<int>(
      0,
      (sum, habitacion) => sum + habitacion.luces.length,
    );
    final totalEncendidas = lista.fold<int>(
      0,
      (sum, habitacion) =>
          sum + habitacion.luces.where((luz) => luz.encendida).length,
    );
    return '$totalEncendidas/$totalLuces';
  }
}
