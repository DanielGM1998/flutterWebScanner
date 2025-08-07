import 'package:flutter/material.dart';
import 'package:flutter_web_qrcode_scanner/flutter_web_qrcode_scanner.dart';
import 'package:http/http.dart' as http;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

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

  void _getExcelWeb(String fechaInicio, String fechaFin) {
    final url = "https://sephora.clase.digital/registro/getExcel/$fechaInicio/$fechaFin";
    html.window.open(url, '_blank');
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
                _getExcelWeb('2025-06-30', '2025-08-07');
              },
              child: const Text('Excel'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UsuariosScreen()),
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
          Navigator.pop(context, result);
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
  List<Map<String, dynamic>> usuarios = [];
  bool loading = true;

  Future<void> fetchUsuarios() async {
    try {
      final response = await http.get(Uri.parse('https://sephora.clase.digital/seg_usuario/getAll/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          usuarios = List<Map<String, dynamic>>.from(data);
          loading = false;
        });
      } else {
        throw Exception('Error al obtener usuarios');
      }
    } catch (e) {
      debugPrint('Error al obtener usuarios: $e');
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(usuario['nombre'] ?? 'Sin nombre'),
                  subtitle: Text(usuario['email'] ?? 'Sin email'),
                );
              },
            ),
    );
  }
}
