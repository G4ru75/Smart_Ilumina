import 'dart:convert';
import 'package:flutter/material.dart';

class ParsedLightData {
  final bool recognized;
  final String? id;
  final String? name;
  final String? type;
  final TimeOfDay? onTime;
  final TimeOfDay? offTime;
  final Color? color;
  final double? intensity; // 0..1
  final bool? isOn;
  final String raw;

  ParsedLightData({
    required this.recognized,
    required this.raw,
    this.id,
    this.name,
    this.type,
    this.onTime,
    this.offTime,
    this.color,
    this.intensity,
    this.isOn,
  });

  ParsedLightData copyWith({
    bool? recognized,
    String? id,
    String? name,
    String? type,
    TimeOfDay? onTime,
    TimeOfDay? offTime,
    Color? color,
    double? intensity,
    bool? isOn,
  }) => ParsedLightData(
    recognized: recognized ?? this.recognized,
    raw: raw,
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    onTime: onTime ?? this.onTime,
    offTime: offTime ?? this.offTime,
    color: color ?? this.color,
    intensity: intensity ?? this.intensity,
    isOn: isOn ?? this.isOn,
  );
}

class LightScanParser {
  static ParsedLightData parse(String raw) {
    try {
      final map = jsonDecode(raw);
      if (map is! Map<String, dynamic>) {
        return ParsedLightData(recognized: false, raw: raw);
      }
      // Intentar esquema B (id,nombre,tipo,horaEncendido,horaApagado)
      if (map.containsKey('id') ||
          map.containsKey('nombre') ||
          map.containsKey('horaEncendido')) {
        final on = _parseTime(map['horaEncendido']);
        final off = _parseTime(map['horaApagado']);
        return ParsedLightData(
          recognized: true,
          raw: raw,
          id: map['id'] as String?,
          name: (map['nombre'] ?? map['name']) as String?,
          type: map['tipo'] as String?,
          onTime: on,
          offTime: off,
        );
      }
      // Intentar esquema A (a,r,g,b,intensity,isOn,name)
      if (['a', 'r', 'g', 'b', 'intensity', 'isOn'].every(map.containsKey)) {
        final a = (map['a'] as num).toInt();
        final r = (map['r'] as num).toInt();
        final g = (map['g'] as num).toInt();
        final b = (map['b'] as num).toInt();
        final col = Color.fromARGB(a, r, g, b);
        final intensity = (map['intensity'] as num).toDouble().clamp(0.0, 1.0);
        final isOn = map['isOn'] as bool;
        return ParsedLightData(
          recognized: true,
          raw: raw,
          name: map['name'] as String?,
          type: 'RGB',
          color: col,
          intensity: intensity,
          isOn: isOn,
        );
      }
      return ParsedLightData(recognized: false, raw: raw);
    } catch (_) {
      return ParsedLightData(recognized: false, raw: raw);
    }
  }

  static TimeOfDay? _parseTime(dynamic value) {
    if (value is String && value.length >= 5) {
      final parts = value.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null && h >= 0 && h < 24 && m >= 0 && m < 60) {
          return TimeOfDay(hour: h, minute: m);
        }
      }
    }
    return null;
  }
}
