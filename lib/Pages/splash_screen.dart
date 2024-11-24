import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Esperar 3 segundos y redirigir a la página principal
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/');
    });

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen del logo
            Image.asset(
              'assets/images/LogoUp.png', // Ajusta la ruta si es necesario
              height: 300,
              width: 300,
            ),
            SizedBox(height: 20),
            // Texto de bienvenida
            Text(
              'Bienvenido a la App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 8, 221, 221),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
