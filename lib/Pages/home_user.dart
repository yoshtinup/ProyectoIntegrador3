import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UserDashboardView extends StatefulWidget {
  const UserDashboardView({Key? key}) : super(key: key);

  @override
  _UserDashboardViewState createState() => _UserDashboardViewState();
}

class _UserDashboardViewState extends State<UserDashboardView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String qrData = "";
  bool _showQR = false;
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  // Subir imagen a la API y obtener la URL
  Future<String?> _uploadImage(File imageFile) async {
    final url = Uri.parse('http://44.214.23.160:3000/upload'); // Cambia según tu configuración
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    try {
      final response = await request.send();
      if (response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        return 'http://44.214.23.160:3000/image/${jsonResponse['filename']}'; // Construir la URL completa
      } else {
        throw Exception('Error al subir la imagen: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al subir la imagen: $e');
      return null;
    }
  }

  // Generar el QR incluyendo la URL de la imagen
  void _generateQRCode() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos y selecciona una imagen'),
          backgroundColor: Colors.black,
        ),
      );
      return;
    }

    // Subir la imagen y obtener la URL
    final imageUrl = await _uploadImage(_selectedImage!);
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al subir la imagen. Intenta nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userData = {
      'Nombre': _nameController.text,
      'Email': _emailController.text,
      'Teléfono': _phoneController.text,
      'ImagenURL': imageUrl, // Añadir la URL de la imagen al QR
    };

    setState(() {
      qrData = jsonEncode(userData);
      _showQR = true;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _editData() {
    setState(() {
      _showQR = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _showQR ? 'Tu Código QR' : 'Generador QR',
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _showQR ? _buildQrView() : _buildInputView(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Nombre',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Correo',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Teléfono',
          icon: Icons.phone_outlined,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _pickImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            side: const BorderSide(color: Colors.cyanAccent, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Seleccionar Imagen',
            style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedImage != null)
          CircleAvatar(
            backgroundImage: FileImage(_selectedImage!),
            radius: 40,
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _generateQRCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            side: const BorderSide(color: Colors.cyanAccent, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Generar QR',
            style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildQrView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15),
          ),
          child: QrImageView(
            data: qrData,
            size: 200,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _editData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            side: const BorderSide(color: Colors.cyanAccent, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Editar Información',
            style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.cyanAccent),
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.cyanAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
        ),
        filled: true,
        fillColor: Colors.black,
      ),
    );
  }
}
