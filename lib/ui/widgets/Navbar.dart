import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/usuarios_controller.dart';
import 'package:smart_ilumina/ui/scaner/scanerpage.dart';
import 'package:smart_ilumina/ui/widgets/user_panel.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    final UsuariosController usuariosController = Get.find();

    return SafeArea(
      child: Container(
        height: kToolbarHeight + 10,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.amber, size: 30),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart💡ilumina',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Valledupar, Cesar',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanerPage()),
                );
                if (resultado != null) {
                  debugPrint('Código QR escaneado: $resultado');
                }
              },
              icon: const Icon(Icons.qr_code, size: 28, color: Colors.black54),
              tooltip: 'Escanear QR',
            ),
            IconButton(
              onPressed: () async {
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
                child: const Icon(Icons.person, color: Colors.blue),
              ),
              tooltip: 'Mi perfil',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
