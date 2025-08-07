import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_web_qrcode_scanner/flutter_web_qrcode_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

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

  Future<void> _getExcel(String fechaInicio, String fechaFin) async {
    final url = "https://sephora.clase.digital/registro/getExcel/$fechaInicio/$fechaFin";

    if (kIsWeb) {
      // En web abre en nueva pestaña
      html.window.open(url, '_blank');
    } else {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se pudo abrir el enlace: $url';
      }
    }
  }

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
            ElevatedButton(
              onPressed: () async {
                _getExcel('2025-07-31', '2025-08-07');
              },
              child: const Text('Excel'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Navega a pantalla de usuarios
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UsuariosScreen(),
                  ),
                );
              },
              child: const Text('Usuarios'),
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
          Navigator.pop(context, result); // Regresa con resultado
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

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  List<dynamic> usuarios = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchUsuarios();
  }

  Future<void> fetchUsuarios() async {
    try {
      final response = await http.get(Uri.parse('https://sephora.clase.digital/seg_usuario/getAll/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map && data.containsKey('result')) {
          setState(() {
            usuarios = data['result'];
            loading = false;
          });
        } else {
          setState(() {
            error = 'Respuesta inesperada de la API';
            loading = false;
          });
        }
      } else {
        setState(() {
          error = 'Error en la respuesta: ${response.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error al obtener usuarios: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar:  AppBar(title: const Text('Usuarios')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Usuarios')),
        body: Center(child: Text(error!)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: ListView.builder(
        itemCount: usuarios.length,
        itemBuilder: (context, index) {
          final user = usuarios[index];
          return ListTile(
            title: Text(user['nombre'] ?? ''),
            subtitle: Text(user['email'] ?? ''),
          );
        },
      ),
    );
  }
}
