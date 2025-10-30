import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/luz_controller.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
    if (lucesController.habitacionActualId.value != widget.habitacionId) {
      lucesController.escucharLucesDeHabitacion(widget.habitacionId);
    }
  }

  void _confirmardesvincularLuz(String luzId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const textoMediano(texto: 'Desvincular luz'),
        content: const TextosPequenos(
          texto: '¿Está seguro de desvincular esta luz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.pop(context);

                Get.dialog(
                  const Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );

                await lucesController.deshabilitarLuz(luzId);
                Get.back();
                Get.back();
                Get.snackbar('Éxito', 'La luz ha sido desvinculada');
              } catch (e) {
                Get.back();
                Get.snackbar('Error', 'No se pudo desvincular la luz');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // Mostrar selector de color completo de pickcolor
  void _mostrarSelectorColor(String luzId, Color colorActual) {
    Color colorTemporal = colorActual;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar color de la luz'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //Color Picker con rueda de colores
                ColorPicker(
                  pickerColor: colorActual,
                  onColorChanged: (Color color) {
                    colorTemporal = color;
                  },
                  pickerAreaHeightPercent: 0.8,
                  enableAlpha: false, // Sin transparencia
                  displayThumbColor: true,
                  labelTypes: const [],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                lucesController.cambiarColor(luzId, colorTemporal);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorTemporal,
                foregroundColor: colorTemporal.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              ),
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final luz = lucesController.luces.firstWhereOrNull(
        (l) => l.id == widget.luzId,
      );

      if (luz == null) {
        return const SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [CircularProgressIndicator()],
          ),
        );
      }

      final titulo = luz.nombre;
      final colorActual = Color(luz.color.value);

      // Colores predefinidos
      final presetsRapidos = <Color>[
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
        Colors.purple,
        Colors.pink,
        Colors.white,
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
                IconButton(
                  onPressed: () => _confirmardesvincularLuz(luz.id),
                  icon: const Icon(Icons.exit_to_app),
                  color: Colors.red,
                  tooltip: 'Desvincular luz',
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 15),

                // Botón principal para abrir selector completo
                Expanded(
                  child: GestureDetector(
                    onTap: () => _mostrarSelectorColor(luz.id, colorActual),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorActual,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.palette,
                            color: colorActual.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Cambiar color',
                            style: TextStyle(
                              color: colorActual.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Switch
                Switch(
                  value: luz.encendida,
                  activeThumbColor: Colors.white,
                  activeTrackColor: colorActual,
                  onChanged: (v) => lucesController.cambiarEstadoLuz(luz.id, v),
                ),
              ],
            ),

            const SizedBox(height: 12),

            //Accesos rápidos a los colores predeterminados
            const Text(
              'Accesos rápidos:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presetsRapidos.map((color) {
                final seleccionado = colorActual.value == color.value;
                return GestureDetector(
                  onTap: () => lucesController.cambiarColor(luz.id, color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: seleccionado
                            ? Colors.black
                            : Colors.grey.shade300,
                        width: seleccionado ? 3 : 2,
                      ),
                      boxShadow: seleccionado
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
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
                        '${(luz.intensidad * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Intensidad', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 180,
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

            const SizedBox(height: 1),
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
                child: const textoMediano(texto: 'Guardar'),
              ),
            ),
          ],
        ),
      );
    });
  }
}
