import 'package:flutter/material.dart';
import 'ArcIntensitySlider.dart';

class ConfigLuzModal extends StatefulWidget {
  final Map<String, dynamic> habitacion;
  final int luzIndex;
  final VoidCallback? onSaved;

  const ConfigLuzModal({
    super.key,
    required this.habitacion,
    required this.luzIndex,
    this.onSaved,
  });

  @override
  State<ConfigLuzModal> createState() => _ConfigLuzModalState();
}

class _ConfigLuzModalState extends State<ConfigLuzModal> {
  late Map<String, dynamic> luz;
  late double intensidad; // 0.0 - 1.0
  late bool encendida;
  late Color colorActual;

  final List<Color> presets = const [
    Color(0xFF1976D2),
    Color(0xFF64B5F6),
    Color(0xFFFFEE58),
    Color(0xFFFFC107),
  ];

  @override
  void initState() {
    super.initState();
    luz =
        (widget.habitacion['luces'] as List)[widget.luzIndex]
            as Map<String, dynamic>;
    intensidad = (luz['intensidad'] ?? 0.47) as double;
    encendida = (luz['encendida'] ?? false) as bool;
    colorActual = (luz['color'] as Color?) ?? const Color(0xFF1976D2);
  }

  void _guardar() {
    luz['intensidad'] = intensidad;
    luz['encendida'] = encendida;
    luz['color'] = colorActual;
    widget.onSaved?.call();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final String titulo = (luz['nombre'] ?? 'Luz') as String;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Center(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 24),
            const SizedBox(width: 6),
            ...presets.map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () => setState(() => colorActual = c),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorActual == c ? Colors.black : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                '${(intensidad * 100).round()}%',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Spacer(),
            Switch(
              value: encendida,
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.blue,
              onChanged: (v) => setState(() => encendida = v),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Luz', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Nivel de Intensidad', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(intensidad * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Intensidad'),
                ],
              ),
            ),
            SizedBox(
              width: 150,
              height: 150,
              child: ArcIntensitySlider(
                color: colorActual,
                value: intensidad,
                onChanged: (v) => setState(() => intensidad = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _guardar,
            child: const Text('Guardar'),
          ),
        ),
      ],
    );
  }
}
