import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String informacion;
  final Color color;

  const InfoCard({
    Key? key,
    required this.icono,
    required this.titulo,
    required this.informacion,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, color: color, size: 28),
          SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            informacion,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
