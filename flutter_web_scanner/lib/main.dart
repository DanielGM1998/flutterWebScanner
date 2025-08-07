// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Web QR Scanner',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? qrResult;
  Uint8List? imageBytes;

  void _pickImageAndScanQR() {
    final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..setAttribute('capture', 'environment'); // ✅ uso correcto
    input.click();

    input.onChange.listen((e) {
      final file = input.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);

        reader.onLoadEnd.listen((event) async {
          final bytes = reader.result as Uint8List;
          setState(() {
            imageBytes = bytes;
          });

          // Crear imagen HTML para dibujar en canvas y usar jsQR
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final img = html.ImageElement(src: url);

          img.onLoad.listen((event) {
            final canvas = html.CanvasElement(
              width: img.width,
              height: img.height,
            );
            final ctx = canvas.context2D;
            ctx.drawImage(img, 0, 0);

            final imageData = ctx.getImageData(0, 0, img.width!, img.height!);

            final result = js.context.callMethod('jsQR', [
              imageData.data,
              img.width,
              img.height,
            ]);

            if (result != null) {
              final data = result['data'];
              setState(() {
                qrResult = data;
              });
            } else {
              setState(() {
                qrResult = 'No se detectó ningún código QR';
              });
            }

            html.Url.revokeObjectUrl(url);
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escáner QR en Flutter Web'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickImageAndScanQR,
              child: const Text('Abrir cámara y escanear QR'),
            ),
            const SizedBox(height: 20),
            if (imageBytes != null)
              Image.memory(
                imageBytes!,
                width: 300,
                height: 300,
              ),
            const SizedBox(height: 20),
            Text(
              qrResult ?? 'Esperando escaneo...',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
