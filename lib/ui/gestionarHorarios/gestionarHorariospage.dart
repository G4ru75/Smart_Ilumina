import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/horarios_controller.dart';
import 'package:smart_ilumina/controllers/luz_controller.dart';
import 'package:smart_ilumina/models/luces_models.dart';
import 'package:smart_ilumina/models/Horarios_models.dart';
import 'package:smart_ilumina/ui/widgets/Navbar.dart';

class HorariosPage extends StatefulWidget {
  const HorariosPage({super.key});

  @override
  State<HorariosPage> createState() => _HorariosPageState();
}

class _HorariosPageState extends State<HorariosPage> {
  //final HorariosController horarioController = Get.find();
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

                                // **NUEVO: Lista de horarios configurados**
                                if (luz.horarios.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.schedule_outlined,
                                          color: Colors.grey.shade600,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Sin horarios configurados',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Horarios configurados:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...luz.horarios.map(
                                        (horario) =>
                                            _buildHorarioCard(luz.id, horario),
                                      ),
                                    ],
                                  ),

                                const SizedBox(height: 12),

                                // **Botón para agregar nuevo horario**
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _mostrarDialogoNuevoHorario(luz.id),
                                    icon: const Icon(Icons.add, size: 20),
                                    label: const Text('Agregar horario'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.blue.shade700,
                                      side: BorderSide(
                                        color: Colors.blue.shade300,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // **Botones de acción rápida**
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          await lucesController
                                              .cambiarEstadoLuz(
                                                luz.id,
                                                !luz.encendida,
                                              );
                                        },
                                        icon: Icon(
                                          luz.encendida
                                              ? Icons.lightbulb_outline
                                              : Icons.lightbulb,
                                          size: 18,
                                        ),
                                        label: Text(
                                          luz.encendida ? 'Apagar' : 'Encender',
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: luz.encendida
                                              ? Colors.red.shade600
                                              : Colors.green.shade600,
                                          side: BorderSide(
                                            color: luz.encendida
                                                ? Colors.red.shade300
                                                : Colors.green.shade300,
                                          ),
                                        ),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // **NUEVO: Widget para cada horario**
  Widget _buildHorarioCard(String luzId, Horarios horario) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: horario.activo ? Colors.blue.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: horario.activo ? Colors.blue.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          // Icono de estado
          Icon(
            horario.activo ? Icons.alarm_on : Icons.alarm_off,
            color: horario.activo ? Colors.blue.shade700 : Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),

          // Horarios
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.wb_sunny,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimeOfDay(horario.horaEncendido),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.nightlight,
                      size: 16,
                      color: Colors.indigo.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimeOfDay(horario.horaApagado),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDiasSemana(horario.diasSemana),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),

          // Switch activar/desactivar
          Switch(
            value: horario.activo,
            onChanged: (value) async {
              await lucesController.toggleHorarios(luzId, horario.id, value);
            },
            activeColor: Colors.blue.shade700,
          ),

          // Botón eliminar
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: Colors.red.shade600,
            onPressed: () => _confirmarEliminarHorario(luzId, horario.id),
          ),
        ],
      ),
    );
  }

  // **NUEVO: Diálogo para agregar horario**
  void _mostrarDialogoNuevoHorario(String luzId) {
    TimeOfDay? horaEncendido;
    TimeOfDay? horaApagado;
    List<int> diasSeleccionados = [1, 2, 3, 4, 5, 6, 7];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nuevo Horario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hora de encendido
                const Text(
                  'Hora de Encendido:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final hora = await showTimePicker(
                      context: context,
                      initialTime: horaEncendido ?? TimeOfDay.now(),
                    );
                    if (hora != null) {
                      setDialogState(() => horaEncendido = hora);
                    }
                  },
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    horaEncendido != null
                        ? _formatTimeOfDay(horaEncendido!)
                        : 'Seleccionar hora',
                  ),
                ),

                const SizedBox(height: 16),

                // Hora de apagado
                const Text(
                  'Hora de Apagado:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final hora = await showTimePicker(
                      context: context,
                      initialTime: horaApagado ?? TimeOfDay.now(),
                    );
                    if (hora != null) {
                      setDialogState(() => horaApagado = hora);
                    }
                  },
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    horaApagado != null
                        ? _formatTimeOfDay(horaApagado!)
                        : 'Seleccionar hora',
                  ),
                ),

                const SizedBox(height: 16),

                // Días de la semana
                const Text(
                  'Días de la semana:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildDiaChip(
                      'Lunes',
                      1,
                      diasSeleccionados,
                      setDialogState,
                    ),
                    _buildDiaChip(
                      'Martes',
                      2,
                      diasSeleccionados,
                      setDialogState,
                    ),
                    _buildDiaChip(
                      'Miércoles',
                      3,
                      diasSeleccionados,
                      setDialogState,
                    ),
                    _buildDiaChip(
                      'Jueves',
                      4,
                      diasSeleccionados,
                      setDialogState,
                    ),
                    _buildDiaChip(
                      'Viernes',
                      5,
                      diasSeleccionados,
                      setDialogState,
                    ),
                    _buildDiaChip(
                      'Sábado',
                      6,
                      diasSeleccionados,
                      setDialogState,
                    ),
                    _buildDiaChip(
                      'Domingo',
                      7,
                      diasSeleccionados,
                      setDialogState,
                    ),
                  ],
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
              onPressed: horaEncendido != null && horaApagado != null
                  ? () async {
                      final nuevoHorario = Horarios(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        horaEncendido: horaEncendido!,
                        horaApagado: horaApagado!,
                        diasSemana: diasSeleccionados,
                        activo: true,
                      );

                      await lucesController.agregarHorario(luzId, nuevoHorario);
                      if (context.mounted) Navigator.pop(context);
                    }
                  : null,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  // **NUEVO: Chip para seleccionar día**
  Widget _buildDiaChip(
    String label,
    int dia,
    List<int> diasSeleccionados,
    StateSetter setDialogState,
  ) {
    final selected = diasSeleccionados.contains(dia);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (value) {
        setDialogState(() {
          if (value) {
            diasSeleccionados.add(dia);
          } else {
            diasSeleccionados.remove(dia);
          }
        });
      },
    );
  }

  // **NUEVO: Confirmar eliminación**
  void _confirmarEliminarHorario(String luzId, String horarioId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Horario'),
        content: const Text('¿Está seguro de eliminar este horario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              //await habitacionesController.eliminarHorario(luzId, horarioId);
              if (context.mounted) Navigator.pop(context);
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

  // **NUEVO: Formatear TimeOfDay**
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // **NUEVO: Formatear días de la semana**
  String _formatDiasSemana(List<int> dias) {
    if (dias.length == 7) return 'Todos los días';
    if (dias.length == 5 &&
        dias.contains(1) &&
        dias.contains(2) &&
        dias.contains(3) &&
        dias.contains(4) &&
        dias.contains(5)) {
      return 'Lunes a Viernes';
    }
    if (dias.length == 2 && dias.contains(6) && dias.contains(7)) {
      return 'Fines de semana';
    }

    const nombres = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return dias.map((d) => nombres[d - 1]).join(', ');
  }
}
