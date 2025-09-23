import 'package:flutter/material.dart';
import 'ConfigLuzModal.dart';

class LucesHabitacionModal extends StatefulWidget {
  final Map<String, dynamic> habitacion;
  final VoidCallback? onChanged;

  const LucesHabitacionModal({
    super.key,
    required this.habitacion,
    this.onChanged,
  });

  @override
  State<LucesHabitacionModal> createState() => _LucesHabitacionModalState();
}

class _LucesHabitacionModalState extends State<LucesHabitacionModal> {
  void _toggleLuz(int index, bool value) {
    setState(() {
      (widget.habitacion['luces'] as List)[index]['encendida'] = value;
    });
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final String nombre = widget.habitacion['nombre'] as String;
    final List luces = widget.habitacion['luces'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Center(
                child: Text(
                  nombre,
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
        const SizedBox(height: 12),
        const Text(
          'Luces',
          style: TextStyle(letterSpacing: 6, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: luces.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final luz = luces[index] as Map<String, dynamic>;
              final String nombreLuz =
                  (luz['nombre'] ?? 'Luz ${index + 1}') as String;
              final bool encendida = (luz['encendida'] ?? false) as bool;
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      nombreLuz,
                      style: const TextStyle(letterSpacing: 3, fontSize: 16),
                    ),
                  ),
                  Switch(
                    value: encendida,
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.green,
                    onChanged: (v) => _toggleLuz(index, v),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: ConfigLuzModal(
                                habitacion: widget.habitacion,
                                luzIndex: index,
                                onSaved: () {
                                  setState(() {});
                                  widget.onChanged?.call();
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.settings, size: 18),
                    label: const Text('Config'),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
