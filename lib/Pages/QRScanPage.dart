import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'QRDetailsPage.dart';
import 'package:http/http.dart' as http;
class QRScanPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onUpdateGuests;

  QRScanPage({Key? key, required this.onUpdateGuests}) : super(key: key);

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isNavigating = false; // Control para evitar múltiples navegaciones


void _processQRContent(String content) async {
  try {
    final jsonData = json.decode(content);
    print("[INFO] Datos del QR procesados: $jsonData");

    // Verificar y actualizar el estado del boleto
    if (jsonData.containsKey('idcodigo')) {
      final String idcodigo = jsonData['idcodigo'];
      print("[INFO] idcodigo encontrado: $idcodigo. Intentando actualizar el estado del boleto...");
      
      // Actualiza el estado del boleto
      await _verificarYActualizarBoleto(idcodigo); // Cambia 'utilizado' al estado deseado

      // Verifica el estado actualizado del boleto
      final estadoActualizado = await _obtenerEstadoBoleto(idcodigo);
      if (estadoActualizado != null) {
        print("[INFO] Estado actualizado del boleto: $estadoActualizado");
        jsonData['status'] = estadoActualizado; // Actualiza el JSON con el estado más reciente
      }
    } else {
      print("[WARNING] idcodigo no encontrado en el contenido del QR.");
    }

    if (!isNavigating) {
      isNavigating = true;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRDetailsPage(jsonData: jsonData),
        ),
      ).then((_) {
        isNavigating = false;
        print("[INFO] Retornado desde QRDetailsPage.");
      });
    }
  } catch (e) {
    print("[ERROR] Error procesando el contenido del QR: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('El código QR no contiene datos válidos'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<String?> _obtenerEstadoBoleto(String idcodigo) async {
  const String apiUrl = "https://apipulserelastik.integrador.xyz/api/v1/boleto";
  try {
    print("[INFO] Consultando el estado del boleto con idcodigo: $idcodigo");
    final response = await http.get(Uri.parse("$apiUrl/$idcodigo"));

    if (response.statusCode == 200) {
      final boletoData = json.decode(response.body);
      print("[INFO] Respuesta del boleto: $boletoData");
      if (boletoData != null && boletoData.containsKey('status')) {
        return boletoData['status'];
      } else {
        print("[WARNING] El boleto no contiene un estado.");
        return null;
      }
    } else {
      print("[ERROR] Error al consultar el estado del boleto. Código: ${response.statusCode}, Respuesta: ${response.body}");
      return null;
    }
  } catch (e) {
    print("[ERROR] Error al obtener el estado del boleto: $e");
    return null;
  }
}

Future<void> _verificarYActualizarBoleto(String idcodigo) async {
  const String apiUrl = "https://apipulserelastik.integrador.xyz/api/v1/boleto";
  try {
    print("[INFO] Consultando el estado del boleto con idcodigo: $idcodigo");
    final response = await http.get(Uri.parse("$apiUrl/$idcodigo"));

    if (response.statusCode == 200) {
      final boletoData = json.decode(response.body);
      print("[INFO] Respuesta del boleto: $boletoData");

      if (boletoData != null && boletoData.containsKey('status')) {
        final String estadoActual = boletoData['status'];
        print("[INFO] Estado actual del boleto: $estadoActual");

        // Determinar el nuevo estado
        String nuevoEstado;
        if (estadoActual == 'pendiente') {
          nuevoEstado = 'adentro';
        } else if (estadoActual == 'adentro') {
          nuevoEstado = 'afuera';
        } else if (estadoActual == 'afuera') {
          nuevoEstado = 'adentro'; // Cambiar de vuelta a 'adentro'
        } else {
          print("[WARNING] Estado desconocido: $estadoActual. No se realizará ningún cambio.");
          return;
        }

        print("[INFO] Intentando actualizar el estado del boleto a: $nuevoEstado");

        // Enviar solicitud PUT para actualizar el estado
        final updateResponse = await http.put(
          Uri.parse("$apiUrl/$idcodigo"),
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode({
            "status": nuevoEstado,
          }),
        );

        if (updateResponse.statusCode == 200) {
          print("[SUCCESS] Estado del boleto actualizado exitosamente a '$nuevoEstado'.");
        } else {
          print("[ERROR] Error al actualizar el estado del boleto. Código de respuesta: ${updateResponse.statusCode}. Respuesta: ${updateResponse.body}");
        }
      } else {
        print("[ERROR] El boleto no contiene un estado válido.");
      }
    } else {
      print("[ERROR] Error al consultar el boleto. Código de respuesta: ${response.statusCode}. Respuesta: ${response.body}");
    }
  } catch (e) {
    print("[ERROR] Error al verificar o actualizar el boleto: $e");
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
                    border: Border.all(color: Colors.cyanAccent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                          _processQRContent(
                              barcode.rawValue ?? 'Código QR no válido');
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Botones de control
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: Icons.flashlight_on,
                    label: "Linterna",
                    onTap: () {
                      cameraController.toggleTorch();
                    },
                  ),
                  _buildControlButton(
                    icon: Icons.flip_camera_android,
                    label: "Cambiar Cámara",
                    onTap: () {
                      cameraController.switchCamera();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.cyanAccent, width: 2),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.cyanAccent),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
