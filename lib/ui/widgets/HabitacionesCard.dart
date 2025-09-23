import 'package:flutter/material.dart';
import 'textos.dart';
import 'LucesHabitacionModal.dart';

class HabitacionesCard extends StatefulWidget {
  const HabitacionesCard({Key? key}) : super(key: key);

  @override
  State<HabitacionesCard> createState() => _HabitacionesCardState();
}

class _HabitacionesCardState extends State<HabitacionesCard> {
  List<Map<String, dynamic>> habitaciones = [
    {
      'nombre': 'Sala',
      'icon': Icons.weekend,
      'color': Colors.blue,
      'luces': [
        {'nombre': 'Luz 1', 'encendida': true},
        {'nombre': 'Luz 2', 'encendida': true},
        {'nombre': 'Luz 3', 'encendida': true},
        {'nombre': 'Luz 4', 'encendida': false},
      ],
    },
    {
      'nombre': 'Dormitorio',
      'icon': Icons.bed,
      'color': Colors.blue,
      'luces': [
        {'nombre': 'Luz 1', 'encendida': false},
        {'nombre': 'Luz 2', 'encendida': true},
        {'nombre': 'Luz 3', 'encendida': false},
      ],
    },
    {
      'nombre': 'Baño',
      'icon': Icons.bathtub,
      'color': Colors.blue,
      'luces': [
        {'nombre': 'Luz 1', 'encendida': false},
      ],
    },
    {
      'nombre': 'Terraza',
      'icon': Icons.deck,
      'color': Colors.green,
      'luces': [
        {'nombre': 'Luz 1', 'encendida': true},
        {'nombre': 'Luz 2', 'encendida': true},
      ],
    },
    {
      'nombre': 'Cocina',
      'icon': Icons.calendar_today,
      'color': Colors.black54,
      'luces': [
        {'nombre': 'Luz 1', 'encendida': false},
        {'nombre': 'Luz 2', 'encendida': false},
        {'nombre': 'Luz 3', 'encendida': false},
        {'nombre': 'Luz 4', 'encendida': false},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    // Inicializa 'valor' y 'progreso' según las luces de cada habitación
    for (final hab in habitaciones) {
      _actualizarProgresoHabitacion(hab);
    }
  }

  void _actualizarProgresoHabitacion(Map<String, dynamic> habitacion) {
    final List luces = (habitacion['luces'] as List? ?? []);
    final int total = luces.length;
    final int encendidas = luces
        .where((l) => (l['encendida'] ?? false) == true)
        .length;
    habitacion['valor'] = total == 0 ? '0/0' : '$encendidas/$total';
    habitacion['progreso'] = total == 0 ? 0.0 : encendidas / total;
  }

  void agregarHabitacion(TextEditingController txtNombreHabitacion) {
    setState(() {
      final nueva = {
        'nombre': txtNombreHabitacion.text.trim(),
        'icon': Icons.home,
        'color': Colors.purple,
        'luces': [
          {'nombre': 'Luz 1', 'encendida': false},
        ],
      };
      _actualizarProgresoHabitacion(nueva);
      habitaciones.add(nueva);
    });
  }

  void mostrarAgregarHabitacionModal() {
    final TextEditingController txtNombreHabitacion = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.black, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Agregar Habitación',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 48), // Para balancear el espacio del back
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(height: 16),
                // Usa tu widget de texto personalizado aquí
                TextoField(
                  titulo: 'Digite el nombre',
                  controlador: txtNombreHabitacion,
                  textoSobre: 'Cuarto de los niños',
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
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
                      if (txtNombreHabitacion.text.trim().isNotEmpty) {
                        agregarHabitacion(txtNombreHabitacion);
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Agregar habitación',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarLucesHabitacionModal(Map<String, dynamic> habitacion) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: LucesHabitacionModal(
              habitacion: habitacion,
              onChanged: () {
                setState(() {
                  _actualizarProgresoHabitacion(habitacion);
                });
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habitaciones',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            SizedBox(height: 12),
            ...habitaciones.map(
              (hab) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: GestureDetector(
                  onTap: () => _mostrarLucesHabitacionModal(hab),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Icon(
                        hab['icon'] as IconData,
                        color: hab['color'] as Color,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hab['nombre'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              (hab['valor'] ?? '') as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: (hab['progreso'] ?? 0.0) as double,
                              minHeight: 7,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                hab['color'] as Color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 18),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: mostrarAgregarHabitacionModal,
                  child: Text(
                    'Agregar habitación',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
