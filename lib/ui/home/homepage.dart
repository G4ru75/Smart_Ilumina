import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/controllers/luz_controller.dart';
import 'package:smart_ilumina/ui/widgets/HabitacionesCard.dart';
import 'package:smart_ilumina/ui/widgets/InfoCard.dart';
import 'package:smart_ilumina/ui/widgets/Navbar.dart';

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
            InfoCard(
              icono: Icons.lightbulb,
              titulo: 'Luces activas',
              informacion: lucesController.progreso,
              color: Colors.yellow[700]!,
            ),
            InfoCard(
              icono: Icons.access_time,
              titulo: 'Horarios',
              informacion: 'Gestionar\nhorarios',
              color: Colors.grey[700]!,
            ),
            InfoCard(
              icono: Icons.flash_on,
              titulo: 'Consumo actual',
              informacion: '12Kw',
              color: Colors.black,
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6ECF5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Navbar(),
            const SizedBox(height: 15),
            _buildInfoCards(),
            const SizedBox(height: 10),
            // El resto del espacio para el card con scroll interno
            const Expanded(child: HabitacionesCard()),
          ],
        ),
      ),
    );
  }
}
