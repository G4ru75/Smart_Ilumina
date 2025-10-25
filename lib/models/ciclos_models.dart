class Ciclos {
  int duracionApagado;
  int duracionEncendido;
  bool activo;

  Ciclos({
    required this.duracionApagado,
    required this.duracionEncendido,
    this.activo = false,
  });

  factory Ciclos.fromMap(Map<String, dynamic> map) {
    return Ciclos(
      duracionApagado: map['duracionApagado'] as int? ?? 0,
      duracionEncendido: map['duracionEncendido'] as int? ?? 0,
      activo: map['activo'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'duracionApagado': duracionApagado,
      'duracionEncendido': duracionEncendido,
      'activo': activo,
    };
  }

  @override
  String toString() {
    return 'Ciclos(encendido: $duracionEncendido, apagado: $duracionApagado, activo: $activo)';
  }
}
