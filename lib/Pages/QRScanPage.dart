import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'QRDetailsPage.dart';

class QRScanPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onUpdateGuests;

  QRScanPage({Key? key, required this.onUpdateGuests}) : super(key: key);

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isNavigating = false; // Control para evitar múltiples navegaciones

  void _processQRContent(String content) {
    try {
      final jsonData = json.decode(content);

      // Actualizar la lista de invitados
      widget.onUpdateGuests(jsonData);

      if (!isNavigating) {
        isNavigating = true;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QRDetailsPage(jsonData: jsonData),
          ),
        ).then((_) {
          isNavigating = false;
        });
      }
    } catch (e) {
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
