import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/ciclos_controller.dart';
import 'package:smart_ilumina/controllers/luz_controller.dart';
import 'package:smart_ilumina/models/ciclos_models.dart';
import 'package:smart_ilumina/models/luces_models.dart';
import 'package:smart_ilumina/models/Horarios_models.dart';
import 'package:smart_ilumina/ui/widgets/Navbar.dart';
import '../../controllers/horarios_controller.dart';

class HorariosPage extends StatefulWidget {
  const HorariosPage({super.key});

  @override
  State<HorariosPage> createState() => _HorariosPageState();
}

class _HorariosPageState extends State<HorariosPage> {
  final HorariosController horarioController = Get.find();
  final LucesController lucesController = Get.find();
  final CiclosController ciclosController = Get.find();

  void _mostrarDialogoCiclo(String luzId, Ciclos? cicloActual) {
    final encendidoController = TextEditingController(
      text: cicloActual?.duracionEncendido.toString() ?? '5',
    );
    final apagadoController = TextEditingController(
      text: cicloActual?.duracionApagado.toString() ?? '5',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.sync, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            Text(cicloActual != null ? 'Editar Ciclo' : 'Configurar Ciclo'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'La luz se encenderá y apagará automáticamente según los tiempos configurados.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Tiempo encendido
              TextField(
                controller: encendidoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Tiempo encendido (segundos)',
                  prefixIcon: Icon(
                    Icons.lightbulb,
                    color: Colors.amber.shade700,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'Cuánto tiempo estará encendida',
                  helperStyle: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Tiempo apagado
              TextField(
                controller: apagadoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Tiempo apagado (segundos)',
                  prefixIcon: Icon(
                    Icons.lightbulb_outline,
                    color: Colors.grey.shade600,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'Cuánto tiempo estará apagada',
                  helperStyle: const TextStyle(fontSize: 12),
                ),
              ),

              if (cicloActual != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cicloActual.activo
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: cicloActual.activo
                          ? Colors.green.shade300
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        cicloActual.activo ? Icons.check_circle : Icons.cancel,
                        color: cicloActual.activo ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cicloActual.activo
                              ? 'Ciclo actualmente activo'
                              : 'Ciclo pausado',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cicloActual.activo
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final encendido = int.tryParse(encendidoController.text);
              final apagado = int.tryParse(apagadoController.text);

              if (encendido == null || apagado == null) {
                Get.snackbar(
                  'Error',
                  'Ingresa valores numéricos válidos',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              if (encendido <= 0 || apagado <= 0) {
                Get.snackbar(
                  'Error',
                  'Los tiempos deben ser mayores a 0',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              Navigator.pop(context);
              await ciclosController.configurarCiclo(
                luzId: luzId,
                duracionEncendido: encendido,
                duracionApagado: apagado,
                activo: true,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(cicloActual != null ? 'Actualizar' : 'Crear y activar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminarCiclo(String luzId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Eliminar Ciclo'),
          ],
        ),
        content: const Text(
          '¿Está seguro de eliminar este ciclo?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ciclosController.eliminarCiclo(luzId);
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

                      await horarioController.agregarHorario(
                        luzId,
                        nuevoHorario,
                      );
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

  void _mostrarDialogoEditarHorario(String luzId, Horarios horarioActual) {
    TimeOfDay? horaEncendido = horarioActual.horaEncendido;
    TimeOfDay? horaApagado = horarioActual.horaApagado;
    List<int> diasSeleccionados = List.from(horarioActual.diasSemana);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Horario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      final horarioEditado = Horarios(
                        id: horarioActual.id,
                        horaEncendido: horaEncendido!,
                        horaApagado: horaApagado!,
                        diasSemana: diasSeleccionados,
                        activo: horarioActual.activo,
                      );

                      await horarioController.editarHorario(
                        luzId,
                        horarioEditado,
                      );
                      if (context.mounted) Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorarioCard(String luzId, Horarios horario) {
    return GestureDetector(
      onTap: () => _mostrarDialogoEditarHorario(luzId, horario),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: horario.activo ? Colors.blue.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: horario.activo ? Colors.blue.shade200 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  horario.activo ? Icons.alarm_on : Icons.alarm_off,
                  color: horario.activo
                      ? Colors.blue.shade700
                      : Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),

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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Colors.blue.shade400,
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        horario.activo ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: horario.activo ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        horario.activo ? 'Activo' : 'Inactivo',
                        style: TextStyle(
                          fontSize: 12,
                          color: horario.activo
                              ? Colors.green.shade700
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: horario.activo,
                        onChanged: (value) async {
                          await horarioController.toggleHorario(
                            luzId,
                            horario.id,
                            value,
                          );
                        },
                        activeColor: Colors.blue.shade700,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red.shade600,
                  onPressed: () {
                    _confirmarEliminarHorario(luzId, horario.id);
                  },
                  tooltip: 'Eliminar horario',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
              await horarioController.eliminarHorario(luzId, horarioId);
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

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

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

                                // Lista de horarios configurados
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

                                // Botón para agregar nuevo horario
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

                                // Sección de ciclos
                                if (luz.ciclos != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: luz.ciclos!.activo
                                          ? Colors.green.shade50
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: luz.ciclos!.activo
                                            ? Colors.green.shade300
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              luz.ciclos!.activo
                                                  ? Icons.sync
                                                  : Icons.sync_disabled,
                                              color: luz.ciclos!.activo
                                                  ? Colors.green.shade700
                                                  : Colors.grey.shade600,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Ciclo configurado',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                      color: luz.ciclos!.activo
                                                          ? Colors
                                                                .green
                                                                .shade700
                                                          : Colors
                                                                .grey
                                                                .shade600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${luz.ciclos!.duracionEncendido}s ON / ${luz.ciclos!.duracionApagado}s OFF',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Switch(
                                              value: luz.ciclos!.activo,
                                              onChanged: (value) async {
                                                await ciclosController
                                                    .toggleCiclo(luz.id, value);
                                              },
                                              activeColor:
                                                  Colors.green.shade700,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () =>
                                                    _mostrarDialogoCiclo(
                                                      luz.id,
                                                      luz.ciclos,
                                                    ),
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 16,
                                                ),
                                                label: const Text(
                                                  'Editar',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.blue.shade700,
                                                  side: BorderSide(
                                                    color: Colors.blue.shade300,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () =>
                                                    _confirmarEliminarCiclo(
                                                      luz.id,
                                                    ),
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 16,
                                                ),
                                                label: const Text(
                                                  'Eliminar',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.red.shade600,
                                                  side: BorderSide(
                                                    color: Colors.red.shade300,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          _mostrarDialogoCiclo(luz.id, null),
                                      icon: const Icon(
                                        Icons.sync_disabled,
                                        size: 20,
                                      ),
                                      label: const Text('Configurar ciclo'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.purple.shade700,
                                        side: BorderSide(
                                          color: Colors.purple.shade300,
                                        ),
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 8),

                                // Botón de acción rápida
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await lucesController.cambiarEstadoLuz(
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
}
