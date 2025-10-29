import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/luz_controller.dart';
import 'package:smart_ilumina/ui/widgets/HabitacionesCard.dart';
import 'package:smart_ilumina/ui/widgets/InfoCard.dart';
import 'package:smart_ilumina/ui/widgets/Navbar.dart';
import 'package:smart_ilumina/utils/lucesProgreso.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LucesController lucesController = Get.find();

  Widget _buildInfoCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Obx(() {
        return Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            StreamBuilder<LucesProgreso>(
              stream: lucesController.progresoGlobalUsuario(),
              builder: (context, snapshot) {
                // Mientras carga
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return InfoCard(
                    icono: Icons.lightbulb,
                    titulo: 'Luces activas',
                    informacion: '...',
                    color: Colors.yellow[700]!,
                  );
                }

                // Si hay error
                if (snapshot.hasError) {
                  return InfoCard(
                    icono: Icons.lightbulb,
                    titulo: 'Luces activas',
                    informacion: '0/0',
                    color: Colors.yellow[700]!,
                  );
                }

                // Obtener el progreso
                final progreso =
                    snapshot.data ??
                    const LucesProgreso(total: 0, encendidas: 0);

                return InfoCard(
                  icono: Icons.lightbulb,
                  titulo: 'Luces activas',
                  informacion: progreso.texto,
                  color: Colors.yellow[700]!,
                );
              },
            ),
            GestureDetector(
              onTap: () {
                Get.toNamed('/horarios');
              },
              child: InfoCard(
                icono: Icons.access_time,
                titulo: 'Horarios',
                informacion: 'Gestionar\nhorarios',
                color: Colors.grey[700]!,
              ),
            ),
            /*InfoCard(
              icono: Icons.flash_on,
              titulo: 'Consumo actual',
              informacion: '12Kw',
              color: Colors.black,
            ),*/
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6ECF5),
      appBar: Navbar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            _buildInfoCards(),
            const SizedBox(height: 40),
            const Expanded(child: HabitacionesCard()),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
