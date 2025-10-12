import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/habitaciones_controller.dart';
import 'package:smart_ilumina/controllers/luz_controller.dart';
import 'package:smart_ilumina/utils/light_scan_parser.dart';

class VincularLuzModal extends StatefulWidget {
  final ParsedLightData data; // datos del QR

  const VincularLuzModal({super.key, required this.data});

  @override
  State<VincularLuzModal> createState() => _VincularLuzModalState();
}

class _VincularLuzModalState extends State<VincularLuzModal> {
  final HabitacionesController habController = Get.find();
  final LucesController luzController = Get.find();

  String? _habitacionIdSeleccionada;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final luzId = widget.data.id ?? '';
    final name = widget.data.name ?? '—';
    final isOn = widget.data.isOn;
    final intensity = widget.data.intensity;
    final color = widget.data.color ?? Colors.grey;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Colors.black, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          final habitaciones = habController.habitacionesList;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vincular luz (Link light)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Info del QR
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('ID: $luzId'),
              if (isOn != null) Text('Estado (State): ${isOn ? 'ON' : 'OFF'}'),
              if (intensity != null)
                Text('Intensidad (Intensity): ${(intensity * 100).round()}%'),
              const SizedBox(height: 16),

              // Selección de habitación
              if (habitaciones.isEmpty)
                const Text(
                  'No hay habitaciones. Cree una para continuar. (No rooms found)',
                )
              else
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Seleccione habitación (Select room)',
                    border: OutlineInputBorder(),
                  ),
                  value: _habitacionIdSeleccionada,
                  items: habitaciones
                      .map(
                        (h) => DropdownMenuItem(
                          value: h.id,
                          child: Text(h.nombre),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _habitacionIdSeleccionada = v),
                ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.pop(context, false),
                      child: const Text('Cancelar / Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          (_saving ||
                              luzId.isEmpty ||
                              _habitacionIdSeleccionada == null)
                          ? null
                          : () async {
                              setState(() => _saving = true);
                              try {
                                // Lógica de vinculación (no modificada)
                                await luzController.vincularALaHabitacion(
                                  luzId: luzId,
                                  habitacionId: _habitacionIdSeleccionada!,
                                );
                                if (mounted) Navigator.pop(context, true);
                              } catch (e) {
                                Get.snackbar(
                                  'Vincular luz',
                                  'No se pudo vincular: $e',
                                );
                              } finally {
                                if (mounted) setState(() => _saving = false);
                              }
                            },
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Vincular / Link'),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
