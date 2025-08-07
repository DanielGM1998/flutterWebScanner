import 'package:flutter/material.dart';
import 'package:flutter_web_qrcode_scanner/flutter_web_qrcode_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'QR Scanner Web',
      home: ScannerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String? qrData;
  final CameraController _controller = CameraController(autoPlay: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escáner QR Web')),
      body: Column(
        children: [
          Expanded(
            child: FlutterWebQrcodeScanner(
              controller: _controller,
              cameraDirection: CameraDirection.back,
              stopOnFirstResult: true,
              onGetResult: (result) {
                setState(() {
                  qrData = result;
                });
                _controller.stopVideoStream();
              },
              // Ancho y alto opcionales, por ejemplo:
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.6,
              onError: (error) {
                debugPrint('Error al escanear QR: ${error.message}');
              },
              onPermissionDeniedError: () {
                debugPrint('Permiso denegado para usar la cámara');
              },
            ),
          ),
          if (qrData != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Resultado: $qrData', style: const TextStyle(fontSize: 18)),
            ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                qrData = null;
              });
              _controller.startVideoStream();
            },
            child: const Text('Reiniciar escaneo'),
          ),
        ],
      ),
    );
  }
}
