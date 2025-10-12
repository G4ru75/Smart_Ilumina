import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/luz_controller.dart';
import 'package:smart_ilumina/ui/widgets/textos.dart';
import 'ArcoIntensidad.dart';

class ConfigLuzModal extends StatefulWidget {
  final String habitacionId;
  final String luzId;
  final VoidCallback? onSaved;

  const ConfigLuzModal({
    super.key,
    required this.habitacionId,
    required this.luzId,
    this.onSaved,
  });

  @override
  State<ConfigLuzModal> createState() => _ConfigLuzModalState();
}

class _ConfigLuzModalState extends State<ConfigLuzModal> {
  final LucesController lucesController = Get.find();

  @override
  void initState() {
    super.initState();
    // Garantiza que estemos escuchando la habitación correcta
    if (lucesController.habitacionActualId.value != widget.habitacionId) {
      lucesController.escucharLucesDeHabitacion(widget.habitacionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final luz = lucesController.luces.firstWhere(
        (l) => l.id == widget.luzId,
        orElse: () => null as dynamic,
      );

      if (luz == null) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final titulo = 'Configurar: ${luz.nombre}';
      final colorActual = Color(
        luz.color.value,
      ); // asegúrate que luz.color sea Color

      final presets = <Color>[
        Colors.blue,
        Colors.yellow,
        Colors.white,
        Colors.red,
        Colors.green,
      ];

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

            // Colores + switch
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 6),
                ...presets.map(
                  (c) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: () => lucesController.cambiarColor(luz.id, c),
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
                Switch(
                  value: luz.encendida,
                  activeThumbColor: Colors.white,
                  activeTrackColor: colorActual,
                  onChanged: (v) => lucesController.cambiarEstadoLuz(luz.id, v),
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Text('Luz', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              'Nivel de Intensidad',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),

            // Intensidad con arco (reactivo)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(luz.intensidad * 100).round()}%',
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
                    value: luz.intensidad,
                    onChanged: (v) =>
                        lucesController.cambiarIntensidadDebounced(luz.id, v),
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
                    value: luz.horaEncendido,
                    onChanged: (v) =>
                        lucesController.cambiarHoras(luz.id, horaEncendido: v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HoraInputField(
                    titulo: 'Hora de Apagado',
                    value: luz.horaApagado,
                    onChanged: (v) =>
                        lucesController.cambiarHoras(luz.id, horaApagado: v),
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
    });
  }
}
