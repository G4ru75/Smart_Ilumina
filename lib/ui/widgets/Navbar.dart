import 'package:flutter/material.dart';
import 'textos.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, size: 28, color: Colors.black),
            ),
            Icon(Icons.lightbulb, color: Colors.yellow[700], size: 32),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextosPequenos(texto: 'Smart💡ilumina'),
                Text(
                  'Valledupar Cesar',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
            Spacer(),
            Icon(Icons.qr_code, size: 28, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
