import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';

class UserDashboardView extends StatefulWidget {
  const UserDashboardView({Key? key}) : super(key: key);

  @override
  _UserDashboardViewState createState() => _UserDashboardViewState();
}

class _UserDashboardViewState extends State<UserDashboardView> {
  String? _tipoController = 'VIP';
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _eventoController = TextEditingController();
  final TextEditingController _lugarController = TextEditingController();
  final String _statusController = "pendiente";
  final String codigo = "";
  String qrData = "";
  bool _showQR = false;
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _validateInputs() async {
    final url = Uri.parse('http://54.235.133.98:5000/analyze');
    try {
      final responses = await Future.wait([
        http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': _phoneController.text}),
        ),
        http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': _eventoController.text}),
        ),
        http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': _lugarController.text}),
        ),
        http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': _nombreController.text}),
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

      _generateQRCode(); // Continúa con la generación del QR
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al analizar entradas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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

// Función que retorna el último 'id'
  Future<String?> fetchLastId() async {
    // URL del endpoint
    final url =
        Uri.parse('https://apipulserelastik.integrador.xyz/api/v1/verific');

    try {
      // Realizar la solicitud GET
      final response = await http.get(url);

      // Verificar si la solicitud fue exitosa
      if (response.statusCode == 200) {
        // Decodificar el cuerpo de la respuesta JSON
        final data = json.decode(response.body);

        // Asegurarse de que 'data' sea una lista
        if (data is List) {
          // Obtener el último elemento de la lista
          final lastItem = data.isNotEmpty ? data.last : null;

          // Extraer el 'id' del último elemento
          final codigo =
              lastItem != null ? lastItem['codigo'] as String? : null;

          return codigo;
        } else {
          print('La respuesta no es una lista.');
          return null;
        }
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Ocurrió un error: $e');
      return null;
    }
  }
//funxcion para extraer el ultimo codigo

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Servicio de ubicación deshabilitado
      print("El servicio de ubicación está deshabilitado.");
      return null;
    }

    // Verificar permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permiso denegado
        print("Permiso de ubicación denegado.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permiso denegado para siempre
      print(
          "Permiso de ubicación denegado permanentemente. No se puede solicitar.");
      return null;
    }

    // Obtener la ubicación actual
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print("Latitud: ${position.latitude}, Longitud: ${position.longitude}");
      return position;
    } catch (e) {
      print("Error al obtener la ubicación: $e");
      return null;
    }
  }

  Future<String?> fetchLocation() async {
    Position? position = await getCurrentLocation();
    if (position != null) {
      return "${position.latitude}, ${position.longitude}";
    } else {
      print("No se pudo obtener la ubicación.");
      return null;
    }
  }

  Future<void> _sendJsonToEndpoint(String imageUrl) async {
    final codigo = await fetchLastId();
    final lugar = await fetchLocation();
    final jsonData = {
      'tipo': _tipoController,
      'codigo': codigo,
      'telefonoTaxi': _phoneController.text,
      'evento': _eventoController.text,
      'lugar': lugar,
      'nombre': _nombreController.text,
      'status': _statusController,
      'url': imageUrl,
    };

    final url =
        Uri.parse('https://apipulserelastik.integrador.xyz/api/v1/boleto');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(jsonData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Datos enviados exitosamente al endpoint adicional'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(
            'Error al enviar los datos: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar los datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _generateQRCode() async {
    final lugar = await fetchLocation();
    final codigo = await fetchLastId();
    if (_tipoController == null ||
        codigo == null ||
        _phoneController.text.isEmpty ||
        _eventoController.text.isEmpty ||
        lugar == null ||
        _nombreController.text.isEmpty ||
        _statusController == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor completa todos los campos y selecciona una imagen'),
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
      'nombre': _nombreController.text,
      'telefonoTaxi': _phoneController.text,
      'codigo': codigo,
      'tipo': _tipoController,
      'evento': _eventoController.text,
      'lugar': lugar,
      'ImagenURL': imageUrl,
    };

    setState(() {
      qrData = jsonEncode(userData);
    });

    final qrFile = await _saveQrAsImage();
    if (qrFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Error al generar el archivo del QR. Intenta nuevamente.'),
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

    await _sendJsonToEndpoint(imageUrl);

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
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/Logo.png',
                    height: 100,
                  ),
                  const SizedBox(height: 20),
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

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.cyanAccent),
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
      dropdownColor: Colors.black,
      iconEnabledColor: Colors.cyanAccent,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  @override
  void initState() {
    super.initState();
    _setCurrentLocation(); // Obtener la ubicación al iniciar la vista
  }

  void _setCurrentLocation() async {
    String? location = await fetchLocation(); // Obtiene las coordenadas
    if (location != null) {
      setState(() {
        _lugarController.text = location; // Actualiza el texto del controlador
      });
    }
  }

  Widget _buildInputView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildDropdown(
          label: 'Tipo',
          items: ['VIP', 'Normal', 'Estudiante'],
          value: _tipoController,
          onChanged: (String? newValue) {
            setState(() {
              _tipoController = newValue;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Teléfono',
          icon: Icons.phone_outlined,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _eventoController,
          label: 'Evento',
          icon: Icons.event,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _lugarController,
          label: 'Dirección (Coordenadas)',
          icon: Icons.location_on,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nombreController,
          label: 'Nombre',
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _pickImage,
          style: _buttonStyle(),
          child: const Text(
            'Seleccionar Imagen',
            style: TextStyle(
                color: Colors.cyanAccent, fontWeight: FontWeight.bold),
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
          onPressed: _validateInputs,
          style: _buttonStyle(),
          child: const Text(
            'Generar QR',
            style: TextStyle(
                color: Colors.cyanAccent, fontWeight: FontWeight.bold),
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
          child: QrImage(
            data: qrData,
            size: 200,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _editData,
          style: _buttonStyle(),
          child: const Text(
            'Editar Información',
            style: TextStyle(
                color: Colors.cyanAccent, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly =
        false, // Agrega el parámetro opcional readOnly con valor por defecto
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly, // Controla si el campo es de solo lectura o editable
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

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black.withOpacity(0.8),
      side: const BorderSide(color: Colors.cyanAccent, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: Colors.cyanAccent.withOpacity(0.3),
      elevation: 10,
    );
  }
}
