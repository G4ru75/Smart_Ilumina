import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/luz_controller.dart';
import 'package:smart_ilumina/models/luces_models.dart'; // <- Agrega este import
import 'package:smart_ilumina/ui/widgets/Navbar.dart';
import 'package:smart_ilumina/ui/widgets/textos.dart';

class HorariosPage extends StatefulWidget {
  const HorariosPage({super.key});

  @override
  State<HorariosPage> createState() => _HorariosPageState();
}

class _HorariosPageState extends State<HorariosPage> {
  final LucesController lucesController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6ECF5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Navbar(),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Gestión de Horarios',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Luces>>(
                stream: lucesController.todasLasLucesVinculadas(),
                builder: (context, snapshot) {
                  // <- Corregir aquí
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error al cargar las luces'),
                    );
                  }

                  final lucesVinculadas = snapshot.data ?? [];
                  if (lucesVinculadas.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hay luces vinculadas',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: lucesVinculadas.length,
                    itemBuilder: (context, i) {
                      final luz = lucesVinculadas[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header de la luz
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: luz.encendida
                                            ? Colors.amber.shade100
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        luz.encendida
                                            ? Icons.lightbulb
                                            : Icons.lightbulb_outline,
                                        color: luz.encendida
                                            ? Colors.amber.shade700
                                            : Colors.grey.shade600,
                                        size: 24,
                                      ),
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
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            luz.encendida
                                                ? 'Encendida'
                                                : 'Apagada',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: luz.encendida
                                                  ? Colors.green.shade600
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (luz.encendida)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${(luz.intensidad * 100).round()}%',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: HoraInputField(
                                        titulo: 'Hora de Encendido',
                                        value: luz.horaEncendido,
                                        onChanged: (nuevaHora) async {
                                          if (nuevaHora != null) {
                                            await lucesController.cambiarHoras(
                                              luz.id,
                                              horaEncendido: nuevaHora,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: HoraInputField(
                                        titulo: 'Hora de Apagado',
                                        value: luz.horaApagado,
                                        onChanged: (nuevaHora) async {
                                          if (nuevaHora != null) {
                                            await lucesController.cambiarHoras(
                                              luz.id,
                                              horaApagado: nuevaHora,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }, // <- Cerrar builder correctamente
              ),
            ),
          ],
        ),
      ),
    );
  }
}
