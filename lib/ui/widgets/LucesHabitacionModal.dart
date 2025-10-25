import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/habitaciones_controller.dart';
import 'package:smart_ilumina/controllers/luz_controller.dart';
import 'package:smart_ilumina/models/luces_models.dart';
import 'ConfigLuzModal.dart';

class LucesHabitacionModal extends StatefulWidget {
  final int habitacionIndex;

  const LucesHabitacionModal({Key? key, required this.habitacionIndex})
    : super(key: key);

  @override
  State<LucesHabitacionModal> createState() => _LucesHabitacionModalState();
}

class _LucesHabitacionModalState extends State<LucesHabitacionModal> {
  final HabitacionesController habitacionesController =
      Get.find<HabitacionesController>();
  final LucesController luzController = Get.find<LucesController>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Colors.black, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Obx(() {
          // Verificar índice
          if (widget.habitacionIndex >=
                  habitacionesController.habitacionesList.length ||
              widget.habitacionIndex < 0) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Habitación no encontrada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('La habitación que buscas ya no existe.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          }

          final habitacion =
              habitacionesController.habitacionesList[widget.habitacionIndex];

          return StreamBuilder<List<Luces>>(
            stream: luzController.lucesStreamDeHabitacion(habitacion.id),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final luces = snap.data ?? <Luces>[];
              final total = luces.length;
              final encendidas = luces.where((l) => l.encendida).length;

              return Column(
                mainAxisSize: MainAxisSize.min,
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
                            habitacion.nombre,
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
                  const SizedBox(height: 16),

                  // Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(habitacion.icon, color: habitacion.color, size: 32),
                      const SizedBox(width: 12),
                      Text(
                        '$encendidas/$total luces',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Lista de luces (colección externa)
                  Flexible(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: luces.isEmpty
                          ? const Center(child: Text('Sin luces vinculadas'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: luces.length,
                              itemBuilder: (context, i) {
                                final luz = luces[i];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          luz.encendida
                                              ? Icons.lightbulb
                                              : Icons.lightbulb_outline,
                                          color: luz.encendida
                                              ? Colors.amber
                                              : Colors.grey,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                luz.nombre,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              if (luz.encendida)
                                                Text(
                                                  '${(luz.intensidad * 100).round()}%',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),

                                        // Configurar
                                        IconButton(
                                          icon: Icon(
                                            Icons.settings,
                                            color: Colors.grey[600],
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  side: const BorderSide(
                                                    color: Colors.black,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    24,
                                                  ),
                                                  child: ConfigLuzModal(
                                                    luzId: luz.id,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                        // Switch encendido
                                        Switch(
                                          value: luz.encendida,
                                          onChanged: (value) => luzController
                                              .cambiarEstadoLuz(luz.id, value),
                                          activeThumbColor: Colors.white,
                                          activeTrackColor: habitacion.color,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botones: encender/apagar todas (sobre colección luces)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            luzController.cambiarEstadoTodas(true);
                          },
                          child: const Text('Encender todas'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            luzController.cambiarEstadoTodas(false);
                          },
                          child: const Text('Apagar todas'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }
}
