import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class RegisterView extends StatefulWidget {
  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController gmailController = TextEditingController();
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final LocalAuthentication auth = LocalAuthentication();
  bool canCheckBiometrics = false;
  bool isBiometricStep = false;

  // Colores de los bordes dinámicos
  Color _nombreBorderColor = Colors.cyanAccent;
  Color _apellidoBorderColor = Colors.cyanAccent;
  Color _telefonoBorderColor = Colors.cyanAccent;
  Color _gmailBorderColor = Colors.cyanAccent;
  Color _usuarioBorderColor = Colors.cyanAccent;
  Color _passwordBorderColor = Colors.cyanAccent;

  @override
  void initState() {
    super.initState();
    checkBiometrics();
  }

  Future<void> checkBiometrics() async {
    bool canCheck = false;
    try {
      canCheck = await auth.canCheckBiometrics;
    } on PlatformException {
      canCheck = false;
    }

    if (!mounted) return;

    setState(() {
      canCheckBiometrics = canCheck;
    });
  }

  Future<void> analyzeInputs() async {
    final url = Uri.parse('http://54.235.133.98:5000/analyze');
    try {
      // Analizar todos los campos relevantes
      final responses = await Future.wait([
        http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'message': nombreController.text})),
        http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'message': apellidoController.text})),
        http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'message': telefonoController.text})),
        http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'message': gmailController.text})),
        http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'message': usuarioController.text})),
        http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'message': passwordController.text})),
      ]);

      // Actualizar colores de los bordes en función de las respuestas
      setState(() {
        _nombreBorderColor = _getBorderColorFromResponse(responses[0]);
        _apellidoBorderColor = _getBorderColorFromResponse(responses[1]);
        _telefonoBorderColor = _getBorderColorFromResponse(responses[2]);
        _gmailBorderColor = _getBorderColorFromResponse(responses[3]);
        _usuarioBorderColor = _getBorderColorFromResponse(responses[4]);
        _passwordBorderColor = _getBorderColorFromResponse(responses[5]);
      });

      // Si algún campo tiene palabras inapropiadas (rojo), mostrar mensaje
      bool hasObsceneWords = [
        _nombreBorderColor,
        _apellidoBorderColor,
        _telefonoBorderColor,
        _gmailBorderColor,
        _usuarioBorderColor,
        _passwordBorderColor,
      ].any((color) => color == Colors.red);

      if (hasObsceneWords) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Se detectaron palabras inapropiadas en algunos campos. Corrige los datos antes de continuar.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Continuar con el registro si no hay palabras inapropiadas
      initiateBiometricStep();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al analizar entradas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getBorderColorFromResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      int obscenasCount = data['obscenas'];
      if (obscenasCount == 0) return Colors.cyanAccent;
      if (obscenasCount <= 2) return Colors.yellow; // Advertencia leve
      if (obscenasCount <= 4) return Colors.orange; // Advertencia alta
      return Colors.red; // Bloqueo
    }
    return Colors.cyanAccent;
  }

  Future<void> initiateRegistration() async {
    // Validaciones básicas
    if (gmailController.text.isEmpty || !gmailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un correo electrónico válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (passwordController.text.isEmpty || passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Analizar entradas antes de continuar
    await analyzeInputs();
  }

  void initiateBiometricStep() {
    setState(() {
      isBiometricStep = true;
    });

    if (canCheckBiometrics) {
      authenticateWithBiometrics();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu dispositivo no soporta autenticación biométrica'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Autentícate para completar el registro',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      print(e);
      return;
    }

    if (authenticated) {
      registerUser();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Autenticación fallida'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> registerUser() async {
    final url = Uri.parse('https://apipulserelastik.integrador.xyz/api/v1/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombreController.text,
          'apellido': apellidoController.text,
          'telefono': telefonoController.text,
          'gmail': gmailController.text,
          'codigo': passwordController.text,
          'usuario': usuarioController.text,
          'biometric_verified': true,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pushReplacementNamed(context, '/homeAdmin');
      } else {
        throw Exception('Error en el registro');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar usuario: $e'),
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
              image: DecorationImage(
                image: AssetImage('assets/subtle_pattern.png'),
                fit: BoxFit.cover,
                opacity: 0.03,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 30),
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
                        'assets/Logo.png',
                        height: 100,
                        
                      ),
                    ),
                  ),
                  _buildTextField(
                    controller: nombreController,
                    hint: 'Nombre',
                    icon: Icons.person_outline,
                    borderColor: _nombreBorderColor,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: apellidoController,
                    hint: 'Apellido',
                    icon: Icons.person_outline,
                    borderColor: _apellidoBorderColor,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: telefonoController,
                    hint: 'Teléfono',
                    icon: Icons.phone_outlined,
                    borderColor: _telefonoBorderColor,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: gmailController,
                    hint: 'Correo electrónico',
                    icon: Icons.email_outlined,
                    borderColor: _gmailBorderColor,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: usuarioController,
                    hint: 'Usuario',
                    icon: Icons.account_circle_outlined,
                    borderColor: _usuarioBorderColor,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: passwordController,
                    hint: 'Contraseña',
                    icon: Icons.lock_outline,
                    borderColor: _passwordBorderColor,
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: initiateRegistration,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        backgroundColor: Colors.black,
                        side: const BorderSide(
                          color: Colors.cyanAccent,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadowColor: Colors.cyanAccent.withOpacity(0.3),
                        elevation: 10,
                      ),
                      child: const Text(
                        'Continuar',
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
    required String hint,
    required IconData icon,
    required Color borderColor,
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
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.cyanAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
