import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminView extends StatelessWidget {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> validateInputsAndLogin(BuildContext context) async {
    final url = Uri.parse('https://tu-servidor-analisis.com/analyze');
    try {
      // Analizar entradas
      final responses = await Future.wait([
        http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': usuarioController.text}),
        ),
        http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': passwordController.text}),
        ),
      ]);

      bool hasObsceneWords = false;
      for (var response in responses) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          int obscenasCount = data['obscenas'];
          if (obscenasCount >= 3) {
            hasObsceneWords = true;
            break;
          }
        } else {
          throw Exception('Error en el análisis: ${response.statusCode}');
        }
      }

      if (hasObsceneWords) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Se detectaron palabras inapropiadas. Corrige los datos antes de continuar.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Si no hay palabras inapropiadas, procede con el inicio de sesión
      loginUser(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al analizar entradas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> loginUser(BuildContext context) async {
    final url = Uri.parse('https://apipulserelastik.integrador.xyz/api/v1/loginNew');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'usuario': usuarioController.text,
        'codigo': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData.containsKey('message') &&
          responseData['message'] == 'Login successful') {
        // Guardar el token recibido (si es necesario)
        final token = responseData['token'];
        print('Token recibido: $token');

        // Redirigir a la página de administrador
        Navigator.pushReplacementNamed(context, '/homeAdmin');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${responseData['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en el inicio de sesión: ${response.body}'),
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
          // Fondo degradado con textura sutil
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
          // Contenido principal
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo con borde fluorescente
                  Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.cyanAccent,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.6),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/Logo.png', // Ruta del logo
                      height: 100, // Altura del logo
                      fit: BoxFit.contain,
                    ),
                  ),
                  _buildTextField(
                    controller: usuarioController,
                    hintText: 'Nombre de usuario o correo',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: passwordController,
                    hintText: 'Contraseña',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => validateInputsAndLogin(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      backgroundColor: Colors.black,
                      side: const BorderSide(color: Colors.cyanAccent, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      shadowColor: Colors.cyanAccent.withOpacity(0.3),
                      elevation: 10,
                    ),
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      '¿No tienes una cuenta? Regístrate aquí',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.cyanAccent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: Colors.cyanAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.black,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
