import 'package:flutter/material.dart';
import 'dart:typed_data'; // Para utilizar Uint8List

class MiQR extends StatelessWidget {
  final Uint8List? qrImage; // Recibimos el QR generado como un Uint8List

  const MiQR({Key? key, this.qrImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dimensiones de la pantalla
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
            mainAxisAlignment: MainAxisAlignment.center, // Centrado vertical
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
              // Contenedor del QR
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
                child: Center(
                  child: qrImage == null
                      ? Image.asset(
                          'assets/QR.png',
                          fit: BoxFit.cover,
                        ) // Imagen por defecto si no hay QR
                      : Image.memory(
                          qrImage!,
                          fit: BoxFit.cover,
                        ), // Mostrar el QR generado
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
