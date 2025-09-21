import 'package:flutter/material.dart';
import 'package:smart_ilumina/ui/scaner/scanerpage.dart';
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
            IconButton(
              onPressed: () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScanerPage()),
                );
                if (resultado != null) {
                  print('Codigo Qr escaneado: $resultado');
                }
              },
              icon: Icon(Icons.qr_code, size: 28, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
