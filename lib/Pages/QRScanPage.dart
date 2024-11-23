import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'QRDetailsPage.dart';  // Importa la vista nueva
import 'dart:convert';


class QRScanPage extends StatefulWidget {
  const QRScanPage({Key? key}) : super(key: key);

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isNavigating = false; // Control para evitar múltiples navegaciones

  void _processQRContent(String content) {
    try {
      final jsonData = json.decode(content);
      if (!isNavigating) {
        isNavigating = true; // Evitar múltiples navegaciones
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QRDetailsPage(jsonData: jsonData),
          ),
        ).then((_) {
          isNavigating = false; // Permitir futuras navegaciones al regresar
        });
      }
    } catch (e) {
      // Manejo de error si el contenido no es JSON válido
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El código QR no contiene datos válidos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black,
                  Color(0xFF1A1A1A),
                ],
              ),
            ),
          ),
          // Contenido del escáner
          Column(
            children: [
              const SizedBox(height: 50),
              const Center(
                child: Text(
                  'Escáner QR',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2D2D2D),
                        const Color(0xFF1A1A1A),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: MobileScanner(
                      controller: cameraController,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          _processQRContent(barcode.rawValue ?? 'Código QR no válido');
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
