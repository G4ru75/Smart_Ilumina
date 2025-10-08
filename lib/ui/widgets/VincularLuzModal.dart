import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/habitaciones_controller.dart';
import 'package:smart_ilumina/models/luces_models.dart';
import 'package:smart_ilumina/utils/light_scan_parser.dart';

class VincularLuzModal extends StatefulWidget {
  final ParsedLightData data;
  const VincularLuzModal({super.key, required this.data});

  @override
  State<VincularLuzModal> createState() => _VincularLuzModalState();
}

class _VincularLuzModalState extends State<VincularLuzModal> {
  final HabitacionesController habitacionesController = Get.find();
  late TextEditingController _nombreCtrl;
  TimeOfDay? _onTime;
  TimeOfDay? _offTime;
  int? _habitacionIndex; // selected index

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(
      text: widget.data.name ?? widget.data.id ?? 'Nueva Luz',
    );
    _onTime = widget.data.onTime ?? const TimeOfDay(hour: 6, minute: 0);
    _offTime = widget.data.offTime ?? const TimeOfDay(hour: 22, minute: 0);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickOnTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _onTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _onTime = picked);
  }

  Future<void> _pickOffTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _offTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _offTime = picked);
  }

  void _confirmar() {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      Get.snackbar('Validación', 'El nombre no puede estar vacío');
      return;
    }
    if (_habitacionIndex == null) {
      Get.snackbar('Validación', 'Seleccione una habitación');
      return;
    }

    final luz = Luces(
      nombre: nombre,
      encendida: widget.data.isOn ?? true,
      intensidad: widget.data.intensity ?? 0.5,
      color: widget.data.color ?? Colors.white,
    );

    habitacionesController.agregarLuzAHabitacion(
      habitacionIndex: _habitacionIndex!,
      luz: luz,
    );

    Get.back();
    Get.snackbar('Luz vinculada', 'La luz "$nombre" fue añadida');
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Colors.black87, width: 1.5),
      ),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Vincular nueva luz',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la luz',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.data.type != null)
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 20),
                      const SizedBox(width: 8),
                      Text('Tipo: ${widget.data.type}'),
                    ],
                  ),
                if (widget.data.type != null) const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _TimeField(
                        label: 'Hora de encendido',
                        time: _onTime,
                        onTap: _pickOnTime,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimeField(
                        label: 'Hora de apagado',
                        time: _offTime,
                        onTap: _pickOffTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GetX<HabitacionesController>(
                  builder: (ctrl) {
                    return DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Seleccione la habitación',
                        border: OutlineInputBorder(),
                      ),
                      value: _habitacionIndex,
                      items: [
                        for (int i = 0; i < ctrl.habitacionesList.length; i++)
                          DropdownMenuItem(
                            value: i,
                            child: Text(ctrl.habitacionesList[i].nombre),
                          ),
                      ],
                      onChanged: (v) => setState(() => _habitacionIndex = v),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _confirmar,
                        child: const Text(
                          'Confirmar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;
  const _TimeField({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = time != null ? _format(time!) : '--:--';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        child: Text(text),
      ),
    );
  }

  String _format(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
