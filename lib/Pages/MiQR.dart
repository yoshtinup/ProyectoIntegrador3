import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Para realizar la solicitud HTTP
import 'dart:convert'; // Para manejar JSON
import 'package:qr_flutter/qr_flutter.dart'; // Mejor opción para generar QR en Flutter

class MiQR extends StatelessWidget {
  const MiQR({Key? key}) : super(key: key);

  // Función para obtener los datos del QR desde la API
  Future<Map<String, dynamic>> fetchQRData() async {
    const apiUrl = 'https://apipulserelastik.integrador.xyz/api/v1/boletos';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>; // Lista de elementos
        // Filtrar por el id 12
        final filteredItem = data.firstWhere(
          (item) => item['id'] == 12,
          orElse: () => throw Exception('No se encontró el ID 12'),
        );
        return filteredItem; // Devuelve solo el objeto con id 12
      } else {
        throw Exception('Error al obtener los datos de la API');
      }
    } catch (e) {
      throw Exception('Error al conectar con la API: $e');
    }
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
                child: FutureBuilder<Map<String, dynamic>>(
                  future: fetchQRData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.cyanAccent,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Error al cargar el QR',
                          style: TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      // Convertir solo campos relevantes a cadena para el QR
                      final filteredData = {
                        'id': snapshot.data!['id'] ?? '',
                        'tipo': snapshot.data!['tipo'] ?? '',
                        'evento': snapshot.data!['evento'] ?? '',
                        'lugar': snapshot.data!['lugar'] ?? '',
                        'telefonoTaxi': snapshot.data!['telefonoTaxi'] ?? '',
                        'ImagenURL': snapshot.data!['url'] ?? '',
                      };

                      final jsonString = jsonEncode(filteredData);

                      // Usar QrImage para generar el QR
                      return QrImage(
                        data: jsonString,
                        version: QrVersions.auto, // Selecciona automáticamente la versión
                        size: screenWidth * 0.6,
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255), // Fondo blanco
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
