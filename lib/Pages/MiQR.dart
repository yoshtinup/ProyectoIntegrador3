import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Para realizar la solicitud HTTP
import 'dart:convert'; // Para manejar JSON
import 'dart:typed_data'; // Para manejar datos binarios
import 'package:qr/qr.dart'; // Para generar el QR

class MiQR extends StatelessWidget {
  const MiQR({Key? key}) : super(key: key);

  // Función para obtener los datos del QR desde la API
  Future<String> fetchQRData() async {
    const apiUrl = 'https://apipulserelastik.integrador.xyz/api/v1/boleto';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['qrData'] ?? 'No data'; // Devuelve el dato del QR o un texto predeterminado
      } else {
        throw Exception('Error al obtener los datos de la API');
      }
    } catch (e) {
      throw Exception('Error al conectar con la API: $e');
    }
  }

  // Función para generar la imagen del QR como Uint8List
  Uint8List generateQR(String data) {
    final qrCode = QrCode(4, QrErrorCorrectLevel.L);
    qrCode.addData(data);
    qrCode.make();

    final int size = qrCode.moduleCount;
    final imageSize = size * 10;

    final Uint8List bytes = Uint8List(imageSize * imageSize);
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        final color = qrCode.isDark(x, y) ? 0xFF : 0x00;
        for (int dx = 0; dx < 10; dx++) {
          for (int dy = 0; dy < 10; dy++) {
            final index = ((y * 10 + dy) * imageSize) + (x * 10 + dx);
            bytes[index] = color;
          }
        }
      }
    }

    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Fondo degradado
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
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Título
              const Text(
                '¡Escanea tu QR!',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.03), // Espaciado dinámico
              // Contenedor del QR usando FutureBuilder
              Container(
                width: screenWidth * 0.6, // 60% del ancho de la pantalla
                height: screenWidth * 0.6, // Mantener proporción cuadrada
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyanAccent, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.6),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: FutureBuilder<String>(
                  future: fetchQRData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.cyanAccent,
                        ),
                      ); // Indicador de carga
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Error al cargar el QR',
                          style: TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                      ); // Mensaje de error
                    } else {
                      final qrBytes = generateQR(snapshot.data!);
                      return Image.memory(
                        qrBytes,
                        fit: BoxFit.contain,
                        color: Colors.white, // Fondo blanco para el QR
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // Espaciado dinámico
              const Text(
                'Muestra este código para tu acceso.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}