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
      title: 'QR Scanner Navegación',
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? qrResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pantalla Principal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QRScannerScreen(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    qrResult = result as String;
                  });
                }
              },
              child: const Text('Escanear QR'),
            ),
            const SizedBox(height: 20),
            Text(
              qrResult != null ? 'Resultado: $qrResult' : 'Aún no se escanea nada',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final CameraController _controller = CameraController(autoPlay: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR')),
      body: FlutterWebQrcodeScanner(
        controller: _controller,
        cameraDirection: CameraDirection.back,
        stopOnFirstResult: true,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        onGetResult: (result) {
          _controller.stopVideoStream();
          Navigator.pop(context, result); // ← Regresa a la pantalla principal con el valor escaneado
        },
        onError: (error) {
          debugPrint('Error: ${error.message}');
        },
        onPermissionDeniedError: () {
          debugPrint('Permiso denegado para usar la cámara');
        },
      ),
    );
  }
}
