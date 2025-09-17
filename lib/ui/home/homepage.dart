import 'package:flutter/material.dart';
import 'package:smart_ilumina/ui/widgets/HabitacionesCard.dart';
import 'package:smart_ilumina/ui/widgets/InfoCard.dart';
import 'package:smart_ilumina/ui/widgets/Navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _buildInfoCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          InfoCard(
            icono: Icons.lightbulb,
            titulo: 'Luces activas',
            informacion: '12/25',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6ECF5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Navbar(),
              SizedBox(height: 20),
              _buildInfoCards(),
              SizedBox(height: 50),
              HabitacionesCard(),
            ],
          ),
        ),
      ),
    );
  }
}
