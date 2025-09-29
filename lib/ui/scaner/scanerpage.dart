import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanerPage extends StatefulWidget {
  const ScanerPage({Key? key}) : super(key: key);

  @override
  State<ScanerPage> createState() => _ScanerPageState();
}

class _ScanerPageState extends State<ScanerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool Escaneado = false;

  void Escaneo(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR Escaneado'),
        content: Text('Código: $code'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, code); // Volver con el resultado
            },
            child: Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                Escaneado = false;
              });
              cameraController.start(); // Reiniciar la cámara
            },
            child: Text('Escanear otro'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanea el codigo qr'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          if (!Escaneado && capture.barcodes.isNotEmpty) {
            setState(() {
              Escaneado = true;
            });
            final String code = capture.barcodes.first.rawValue ?? '';
            cameraController
                .stop(); // Pausar la cámara mientras se muestra el diálogo
            Escaneo(code);
          }
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
