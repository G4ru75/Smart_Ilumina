import 'package:flutter/material.dart';

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
      'valor': '4/5',
      'progreso': 0.9,
      'color': Colors.blue,
    },
    {
      'nombre': 'Dormitorio',
      'icon': Icons.bed,
      'valor': '4/5',
      'progreso': 0.9,
      'color': Colors.blue,
    },
    {
      'nombre': 'Baño',
      'icon': Icons.bathtub,
      'valor': '0/5',
      'progreso': 0.0,
      'color': Colors.blue,
    },
    {
      'nombre': 'Terraza',
      'icon': Icons.deck,
      'valor': '4/5',
      'progreso': 0.9,
      'color': Colors.green,
    },
    {
      'nombre': 'Cocina',
      'icon': Icons.calendar_today,
      'valor': '0/5',
      'progreso': 0.0,
      'color': Colors.black54,
    },
  ];

  void agregarHabitacion() {
    setState(() {
      habitaciones.add({
        'nombre': 'Nueva',
        'icon': Icons.home,
        'valor': '0/1',
        'progreso': 0.0,
        'color': Colors.purple,
      });

      setState(() {});
    });
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
                child: Row(
                  children: [
                    Icon(
                      hab['icon'] as IconData,
                      color: hab['color'] as Color,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hab['nombre'] as String,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            hab['valor'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: hab['progreso'] as double,
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
                  onPressed: agregarHabitacion,
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
