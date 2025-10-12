import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/utils/light_scan_parser.dart';
import 'package:smart_ilumina/ui/widgets/VincularLuzModal.dart';

class ScanerPage extends StatefulWidget {
  const ScanerPage({super.key});

  @override
  State<ScanerPage> createState() => _ScanerPageState();
}

class _ScanerPageState extends State<ScanerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handling = false;

  Future<void> _handleCode(String? raw) async {
    if (_handling || raw == null || raw.trim().isEmpty) return;
    final parsed = LightScanParser.parse(raw);
    if (!parsed.recognized || parsed.id == null || parsed.id!.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR inválido / Invalid QR')),
        );
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
          const SnackBar(
            content: Text('Luz vinculada con éxito (Linked successfully)'),
          ),
        );
        Navigator.of(context).maybePop(); // opcional: volver atrás tras éxito
      }
    } finally {
      // Permitir nuevos escaneos si sigues en esta pantalla
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
      appBar: AppBar(title: const Text('Escanear luz / Scan light')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final codes = capture.barcodes;
              if (codes.isEmpty) return;
              _handleCode(codes.first.rawValue);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Apunte al QR de la luz • Point to the light QR',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.cameraswitch),
        onPressed: () => _controller.switchCamera(),
      ),
    );
  }
}
