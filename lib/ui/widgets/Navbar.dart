import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/usuarios_controller.dart';
import 'package:smart_ilumina/ui/scaner/scanerpage.dart';
import 'package:smart_ilumina/ui/widgets/user_panel.dart';
import 'textos.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    final UsuariosController usuariosController = Get.find();

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.yellow[700], size: 30),
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
              tooltip: 'Escanear QR',
            ),
            // Botón de usuario que abre el panel
            IconButton(
              onPressed: () async {
                // Siempre recargar los datos del usuario al abrir el panel
                await usuariosController.getUserData();

                if (context.mounted) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const UserPanel(),
                  );
                }
              },
              icon: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.person, color: Colors.blue[700], size: 24),
              ),
              tooltip: 'Mi perfil',
            ),
          ],
        ),
      ),
    );
  }
}
