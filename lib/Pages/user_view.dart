import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserView extends StatefulWidget {
  @override
  _UserViewState createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Color _emailBorderColor = Colors.cyanAccent;
  Color _passwordBorderColor = Colors.cyanAccent;

  bool _canContinue = true;

  Future<void> _analyzeAndEvaluate() async {
    final url = Uri.parse('http://54.235.133.98:5000/analyze');
    try {
      // Evaluar correo y contraseña simultáneamente
      final responses = await Future.wait([
        http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': _emailController.text}),
        ),
        http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': _passwordController.text}),
        ),
      ]);

      // Evaluar respuestas
      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final emailResponse = jsonDecode(responses[0].body);
        final passwordResponse = jsonDecode(responses[1].body);

        int emailObscenas = emailResponse['obscenas'];
        int passwordObscenas = passwordResponse['obscenas'];

        setState(() {
          _emailBorderColor = _getBorderColor(emailObscenas);
          _passwordBorderColor = _getBorderColor(passwordObscenas);

          // Bloquear si cualquiera de las frases tiene 3+ palabras inapropiadas
          _canContinue = emailObscenas < 3 && passwordObscenas < 3;
        });

        if (!_canContinue) {
          _showBlockedDialog();
        } else {
          _proceedToNextScreen();
        }
      } else {
        print('Error en el servidor: ${responses[0].statusCode} / ${responses[1].statusCode}');
      }
    } catch (e) {
      print('Error al analizar el texto: $e');
    }
  }


  Future<void> _login() async {
    final url = Uri.parse('https://apipulserelastik.integrador.xyz/api/v1/loginNew');
    try {
      // Realiza la petición POST al endpoint de login
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Verifica si el login fue exitoso según la respuesta del servidor
        if (data['success'] == true) {
          _proceedToNextScreen();
        } else {
          _showErrorDialog('Credenciales incorrectas. Intente nuevamente.');
        }
      } else {
        _showErrorDialog('Error en el servidor. Intente más tarde.');
      }
    } catch (e) {
      print('Error durante el login: $e');
      _showErrorDialog('Error al conectarse con el servidor. Verifique su conexión.');
    }
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }


  Color _getBorderColor(int obscenasCount) {
    if (obscenasCount == 0) {
      return Colors.cyanAccent; // Normal
    } else if (obscenasCount == 1) {
      return Colors.yellow; // Advertencia leve
    } else if (obscenasCount == 2) {
      return Colors.orange; // Advertencia alta
    } else {
      return Colors.red; // Bloqueado
    }
  }

  void _showBlockedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Acceso Denegado'),
          content: const Text(
              'Se han detectado frases inapropiadas. Por favor, corrija los datos antes de continuar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _proceedToNextScreen() {
    Navigator.pushReplacementNamed(context, '/homeUsuario');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado con textura
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
          // Contenido principal centrado
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'Correo electrónico',
                      icon: Icons.email_outlined,
                      borderColor: _emailBorderColor,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _passwordController,
                      hint: 'Contraseña',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      borderColor: _passwordBorderColor,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _analyzeAndEvaluate,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        backgroundColor: Colors.black.withOpacity(0.8),
                        side: const BorderSide(
                          color: Colors.cyanAccent,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color borderColor,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.cyanAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
