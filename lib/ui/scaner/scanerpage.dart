import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/utils/light_scan_parser.dart';
import 'package:smart_ilumina/ui/widgets/VincularLuzModal.dart';

class ScanerPage extends StatefulWidget {
  const ScanerPage({Key? key}) : super(key: key);

  @override
  State<ScanerPage> createState() => _ScanerPageState();
}

class _ScanerPageState extends State<ScanerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _procesando = false;

  void _onCode(String code) {
    final parsed = LightScanParser.parse(code);
    if (!parsed.recognized) {
      Get.snackbar(
        'QR no reconocido',
        'El código escaneado no pertenece a una luz válida',
      );
      _resetScan();
      return;
    }
    Get.dialog(VincularLuzModal(data: parsed), barrierDismissible: false).then((
      _,
    ) {
      // Al cerrar el modal (confirmado o cancelado) salimos de la pantalla para volver al flujo anterior
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _resetScan() {
    setState(() => _procesando = false);
    cameraController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanea el código QR'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          if (_procesando) return;
          if (capture.barcodes.isEmpty) return;
          final code = capture.barcodes.first.rawValue ?? '';
          if (code.isEmpty) return;
          setState(() => _procesando = true);
          cameraController.stop();
          _onCode(code);
        },
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
