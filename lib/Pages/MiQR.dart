import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Para realizar la solicitud HTTP
import 'dart:convert'; // Para manejar JSON
import 'package:qr_flutter/qr_flutter.dart'; // Mejor opción para generar QR en Flutter

class MiQR extends StatelessWidget {
  const MiQR({Key? key}) : super(key: key);

  // Función para obtener los datos del QR desde la API
  Future<List<Map<String, dynamic>>> fetchQRData() async {
    const apiUrl = 'https://apipulserelastik.integrador.xyz/api/v1/boletos';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        print(response.body); // Imprimir el JSON completo en la consola

        final data = jsonDecode(response.body) as List<dynamic>; // Lista de elementos
        // Filtrar por el código
        final String codigo = await fetchCodigo();

        // Obtener todos los elementos que tengan el mismo código
        final filteredItems = data.where(
          (item) => item['codigo'] == codigo,
        ).toList();  // Convierte el Iterable en una lista

        if (filteredItems.isEmpty) {
          throw Exception('No se encontró ningún item con el código $codigo');
        }

        // Asegurarse de que todos los elementos sean del tipo Map<String, dynamic>
        final List<Map<String, dynamic>> result = filteredItems.map((item) {
          // Renombrar la clave "url" a "ImagenURL" para cada elemento
          item['ImagenURL'] = item['url']; // Agregar "ImagenURL" al objeto
          item.remove('url'); // Eliminar la clave "url"
          return item as Map<String, dynamic>; // Asegurarse de que el tipo sea Map<String, dynamic>
        }).toList();

        return result; // Devuelve la lista de objetos con la clave renombrada
      } else {
        throw Exception('Error al obtener los datos de la API');
      }
    } catch (e) {
      throw Exception('Error al conectar con la API: $e');
    }
  }

  Future<String> fetchCodigo() async {
    final url = Uri.parse('https://apipulserelastik.integrador.xyz/api/v1/verific');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);

      // Verifica la longitud de la respuesta
      print('Longitud de la respuesta JSON: ${jsonResponse.length}');
      print(jsonResponse);  // Imprimir la respuesta completa

      if (jsonResponse.isNotEmpty) {
        String codigo = jsonResponse.last['codigo'];
        print('Último código extraído: $codigo');
        return codigo;
      } else {
        throw Exception('No se encontraron datos en la respuesta');
      }
    } else {
      throw Exception('Error al conectar con la API');
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
                child: FutureBuilder<List<Map<String, dynamic>>>(
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
                      if (snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'No se encontraron datos para este código.',
                            style: TextStyle(color: Colors.redAccent),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      // Usamos ListView para mostrar todos los QR
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final item = snapshot.data![index];
                          final filteredData = {
                            'tipo': item['tipo'] ?? '',
                            'evento': item['evento'] ?? '',
                            'lugar': item['lugar'] ?? '',
                            'telefonoTaxi': item['telefonoTaxi'] ?? '',
                            'ImagenURL': item['ImagenURL'] ?? '',
                          };

                          final jsonString = jsonEncode(filteredData);

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: QrImage(
                              data: jsonString,
                              version: QrVersions.auto, // Selecciona automáticamente la versión
                              size: screenWidth * 0.6,
                              backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Fondo blanco
                            ),
                          );
                        },
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
