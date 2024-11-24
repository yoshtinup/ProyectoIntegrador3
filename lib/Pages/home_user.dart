import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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

  // Subir archivo al servidor (para imágenes y QR)
  Future<String?> _uploadFile(File file, String endpoint) async {
    final url = Uri.parse('http://44.214.23.160:3000/$endpoint');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath(
      endpoint == 'save-qr' ? 'qr' : 'image',
      file.path,
    ));

    try {
      final response = await request.send();
      if (response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        return 'http://44.214.23.160:3000/image/${jsonResponse['filename']}';
      } else {
        throw Exception('Error al subir archivo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al subir archivo: $e');
      return null;
    }
  }

  // Guardar el QR como archivo de imagen temporal
  Future<File?> _saveQrAsImage() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/qr_code.png';

      final qrPainter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        gapless: false,
      );

      final picData = await qrPainter.toImageData(2048);
      final bytes = picData!.buffer.asUint8List();

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      print('Error al guardar el QR: $e');
      return null;
    }
  }

  // Generar el QR y subirlo
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

    final imageUrl = await _uploadFile(_selectedImage!, 'upload');
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
      'ImagenURL': imageUrl,
    };

    setState(() {
      qrData = jsonEncode(userData);
    });

    final qrFile = await _saveQrAsImage();
    if (qrFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al generar el archivo del QR. Intenta nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final qrUrl = await _uploadFile(qrFile, 'save-qr');
    if (qrUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al subir el QR. Intenta nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('QR generado y subido exitosamente: $qrUrl'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
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
          image: DecorationImage(
            image: AssetImage('assets/subtle_pattern.png'),
            fit: BoxFit.cover,
            opacity: 0.03,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo con borde fluorescente
                  Container(
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
                      'assets/Logo.png', // Ruta del logo
                      height: 100, // Tamaño del logo
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(
                    _showQR ? 'Tu Código QR' : 'Generador QR',
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.cyanAccent,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
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
            backgroundColor: Colors.black.withOpacity(0.8),
            side: const BorderSide(color: Colors.cyanAccent, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadowColor: Colors.cyanAccent.withOpacity(0.3),
            elevation: 10,
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
            backgroundColor: Colors.black.withOpacity(0.8),
            side: const BorderSide(color: Colors.cyanAccent, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadowColor: Colors.cyanAccent.withOpacity(0.3),
            elevation: 10,
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
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.cyanAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
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
            backgroundColor: Colors.black.withOpacity(0.8),
            side: const BorderSide(color: Colors.cyanAccent, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadowColor: Colors.cyanAccent.withOpacity(0.3),
            elevation: 10,
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
        fillColor: Colors.black.withOpacity(0.8),
      ),
    );
  }
}
