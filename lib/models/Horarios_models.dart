import 'package:flutter/material.dart';

class Horarios {
  String id;
  TimeOfDay horaEncendido;
  TimeOfDay horaApagado;
  List<int> diasSemana;
  bool activo;

  Horarios({
    required this.id,
    required this.horaEncendido,
    required this.horaApagado,
    this.diasSemana = const [1, 2, 3, 4, 5, 6, 7],
    this.activo = false,
  });

  factory Horarios.fromMap(Map<String, dynamic> map) {
    final horaEncendidoMap = map['horaEncendido'] as Map<String, dynamic>?;
    final horaApagadoMap = map['horaApagado'] as Map<String, dynamic>?;

    return Horarios(
      id: map['id'] ?? UniqueKey().toString(),
      horaEncendido: horaEncendidoMap != null
          ? TimeOfDay(
              hour: horaEncendidoMap['hora'] ?? 0,
              minute: horaEncendidoMap['minuto'] ?? 0,
            )
          : const TimeOfDay(hour: 0, minute: 0),
      horaApagado: horaApagadoMap != null
          ? TimeOfDay(
              hour: horaApagadoMap['hora'] ?? 0,
              minute: horaApagadoMap['minuto'] ?? 0,
            )
          : const TimeOfDay(hour: 0, minute: 0),
      diasSemana: List<int>.from(map['diasSemana'] ?? [1, 2, 3, 4, 5, 6, 7]),
      activo: map['activo'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'horaEncendido': {
        'hora': horaEncendido.hour,
        'minuto': horaEncendido.minute,
      },
      'horaApagado': {'hora': horaApagado.hour, 'minuto': horaApagado.minute},
      'diasSemana': diasSemana,
      'activo': activo,
    };
  }

  @override
  String toString() {
    return 'Horario(${horaEncendido.format})-${horaApagado.format}, activo: $activo';
  }
}
