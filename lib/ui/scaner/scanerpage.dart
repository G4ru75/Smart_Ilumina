import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_ilumina/ui/widgets/Navbar.dart';
import 'package:smart_ilumina/utils/light_scan_parser.dart';
import 'package:smart_ilumina/ui/widgets/VincularLuzModal.dart';

class ScanerPage extends StatefulWidget {
  const ScanerPage({super.key});

  @override
  State<ScanerPage> createState() => _ScanerPageState();
}

class _ScanerPageState extends State<ScanerPage>
    with SingleTickerProviderStateMixin {
  // 👈 Necesario para vsync
  late final MobileScannerController _controller;
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  Future<void> _handleCode(String? raw) async {
    if (_handling || raw == null || raw.trim().isEmpty) return;

    final parsed = LightScanParser.parse(raw);
    if (!parsed.recognized || parsed.id == null || parsed.id!.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('QR inválido')));
      }
      return;
    }

    _handling = true;
    try {
      final result = await Get.dialog(
        VincularLuzModal(data: parsed),
        barrierDismissible: false,
      );
      if (mounted && result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Luz vinculada con éxito')),
        );
        Navigator.of(context).pop(); // volver atrás tras éxito
      }
    } finally {
      _handling = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final codes = capture.barcodes;
                if (codes.isEmpty) return;
                _handleCode(codes.first.rawValue);
              },
            ),

            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.9),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Apunte al código QR de la luz',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),

            // --- Botón flotante para cambiar cámara ---
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFFD6C1F9),
                child: const Icon(Icons.cameraswitch, color: Colors.black),
                onPressed: () => _controller.switchCamera(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
