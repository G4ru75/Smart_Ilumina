import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/habitaciones_controller.dart';
import 'package:smart_ilumina/ui/widgets/textos.dart';
import 'ArcoIntensidad.dart';

class ConfigLuzModal extends StatefulWidget {
  final int habitacionIndex;
  final int luzIndex;
  final VoidCallback? onSaved;

  const ConfigLuzModal({
    super.key,
    required this.habitacionIndex,
    required this.luzIndex,
    this.onSaved,
  });

  @override
  State<ConfigLuzModal> createState() => _ConfigLuzModalState();
}

class _ConfigLuzModalState extends State<ConfigLuzModal> {
  final HabitacionesController habitacionesController =
      Get.find<HabitacionesController>();

  late bool encendida;
  late double intensidad; // 0.0 - 1.0
  late Color colorActual;
  TimeOfDay? horaEncendido;
  TimeOfDay? horaApagado;

  final List<Color> presets = const [
    Colors.blue,
    Colors.yellow,
    Colors.white,
    Colors.red,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    final luz = habitacionesController
        .habitacionesList[widget.habitacionIndex]
        .luces[widget.luzIndex];

    encendida = luz.encendida;
    intensidad = luz.intensidad;
    colorActual = luz.color;
    horaEncendido = luz.horaEncendido;
    horaApagado = luz.horaApagado;
  }

  @override
  Widget build(BuildContext context) {
    final hab = habitacionesController.habitacionesList[widget.habitacionIndex];
    final luz = hab.luces[widget.luzIndex];
    final String titulo = 'Configurar: ${luz.nombre}';

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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

          // Colores rápidos + estado + porcentaje
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 24),
              const SizedBox(width: 6),
              ...presets.map(
                (c) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => colorActual = c);
                      habitacionesController.cambiarColorLuz(
                        widget.habitacionIndex,
                        widget.luzIndex,
                        c,
                      );
                    },
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorActual.value == c.value
                              ? Colors.black
                              : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Switch reactivo: se mueve solo cuando el controlador cambia el estado
              Obx(() {
                final value = habitacionesController
                    .habitacionesList[widget.habitacionIndex]
                    .luces[widget.luzIndex]
                    .encendida;

                return Switch(
                  value: value,
                  activeThumbColor: Colors.white,
                  activeTrackColor: hab.color,
                  onChanged: (v) {
                    habitacionesController.cambiarEstadoLuz(
                      widget.habitacionIndex,
                      widget.luzIndex,
                      v,
                    );
                  },
                );
              }),
            ],
          ),

          const SizedBox(height: 8),
          const Text('Luz', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            'Nivel de Intensidad',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),

          // Intensidad con arco
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
                child: ArcoIntensidad(
                  color: colorActual,
                  value: intensidad,
                  onChanged: (v) {
                    setState(() => intensidad = v);
                    habitacionesController.cambiarIntensidadLuzDebounced(
                      widget.habitacionIndex,
                      widget.luzIndex,
                      v,
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: HoraInputField(
                  titulo: 'Hora de Encendido',
                  value: horaEncendido,
                  onChanged: (v) {
                    setState(() => horaEncendido = v);
                    habitacionesController.cambiarHorasLuz(
                      widget.habitacionIndex,
                      widget.luzIndex,
                      horaEncendido: v,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HoraInputField(
                  titulo: 'Hora de Apagado',
                  value: horaApagado,
                  onChanged: (v) {
                    setState(() => horaApagado = v);
                    habitacionesController.cambiarHorasLuz(
                      widget.habitacionIndex,
                      widget.luzIndex,
                      horaApagado: v,
                    );
                  },
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
              onPressed: () {
                widget.onSaved?.call();
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}
