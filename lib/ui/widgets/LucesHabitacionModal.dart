import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/habitaciones_controller.dart';
import 'ConfigLuzModal.dart';

class LucesHabitacionModal extends StatelessWidget {
  final int habitacionIndex;

  const LucesHabitacionModal({Key? key, required this.habitacionIndex})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HabitacionesController controller =
        Get.find<HabitacionesController>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.black, width: 2),
      ),
      child: Container(
        padding: EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Obx(() {
          // Verificar si el índice es válido
          if (habitacionIndex >= controller.habitacionesList.length ||
              habitacionIndex < 0) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Habitación no encontrada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 8),
                Text('La habitación que buscas ya no existe.'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cerrar'),
                ),
              ],
            );
          }

          final habitacion = controller.habitacionesList[habitacionIndex];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con botón de regresar y título
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        habitacion
                            .nombre, // ✅ CORREGIDO: Muestra el nombre correcto
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 48),
                ],
              ),
              SizedBox(height: 16),

              // Info de la habitación
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(habitacion.icon, color: habitacion.color, size: 32),
                  SizedBox(width: 12),
                  Text(
                    '${habitacion.valor} luces',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Lista de luces
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: habitacion.luces.length,
                    itemBuilder: (context, luzIndex) {
                      final luz = habitacion.luces[luzIndex];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
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
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      luz.nombre,
                                      style: TextStyle(
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

                              // ✅ AGREGADO: Botón de configuración
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
                                        borderRadius: BorderRadius.circular(18),
                                        side: BorderSide(
                                          color: Colors.black,
                                          width: 2,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(24),
                                        child: ConfigLuzModal(
                                          habitacionIndex: habitacionIndex,
                                          luzIndex: luzIndex,
                                          onSaved: () {
                                            // Actualizar en el controlador
                                            controller.habitacionesList
                                                .refresh();
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              Switch(
                                value: luz.encendida,
                                onChanged: (value) {
                                  controller.cambiarEstadoLuz(
                                    habitacionIndex,
                                    luzIndex,
                                    value,
                                  );
                                },
                                activeColor: habitacion.color,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        controller.cambiarEstadoTodasLuces(
                          habitacionIndex,
                          true,
                        );
                      },
                      child: Text('Encender todas'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        controller.cambiarEstadoTodasLuces(
                          habitacionIndex,
                          false,
                        );
                      },
                      child: Text('Apagar todas'),
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
