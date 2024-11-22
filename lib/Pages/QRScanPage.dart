import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart'; // Para copiar al portapapeles
import 'dart:convert'; // Para decodificar JSON

class QRScanPage extends StatefulWidget {
  const QRScanPage({Key? key}) : super(key: key);

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  String qrCode = 'No se ha escaneado ningún código';
  String? imageUrl;
  MobileScannerController cameraController = MobileScannerController();
  bool _isDialogVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Escanear Código QR',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.white);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellowAccent);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front, color: Colors.white);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear, color: Colors.white);
                }
              },
            ),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black54,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (!_isDialogVisible) {
                        setState(() {
                          qrCode = barcode.rawValue ?? 'Código QR no válido';
                          imageUrl = _extractImageUrl(qrCode);
                        });
                        _showResultDialog(context, qrCode);
                      }
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Contenido del QR:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    qrCode,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (imageUrl != null)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShowImageScreen(imageUrl: imageUrl!),
                          ),
                        );
                      },
                      child: const Text('Ver Imagen'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(BuildContext context, String code) {
    setState(() {
      _isDialogVisible = true;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            'Código QR Detectado',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Text(
              code,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Copiar', style: TextStyle(color: Colors.tealAccent)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código copiado al portapapeles')),
                );
                Navigator.of(context).pop();
              },
            ),
            if (imageUrl != null)
              TextButton(
                child: const Text('Ver Imagen', style: TextStyle(color: Colors.tealAccent)),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowImageScreen(imageUrl: imageUrl!),
                    ),
                  );
                },
              ),
            TextButton(
              child: const Text('Cerrar', style: TextStyle(color: Colors.tealAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) {
      setState(() {
        _isDialogVisible = false;
      });
    });
  }

  String? _extractImageUrl(String code) {
    try {
      final Map<String, dynamic> data = jsonDecode(code);
      return data['ImagenURL'] as String?;
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

class ShowImageScreen extends StatelessWidget {
  final String imageUrl;

  ShowImageScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Imagen Escaneada'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}