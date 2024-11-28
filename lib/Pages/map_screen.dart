import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final String lugar;

  const MapScreen({Key? key, required this.lugar}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _controller;
  late LatLng _location;

  @override
  void initState() {
    super.initState();
    _parseLocation(); // Parseamos las coordenadas recibidas
  }

  // Parsear las coordenadas que vienen en el formato 'lat, lon'
  void _parseLocation() {
    final coords = widget.lugar.split(', ');
    final lat = double.parse(coords[0]);
    final lon = double.parse(coords[1]);
    setState(() {
      _location = LatLng(lat, lon);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ubicación del Invitado',
          style: TextStyle(color: Colors.cyanAccent),
        ),
        backgroundColor: Colors.black,
        elevation: 5,
        shadowColor: Colors.cyanAccent.withOpacity(0.3),
      ),
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
        child: _location == null
            ? const Center(child: CircularProgressIndicator())
            : Container(
                margin: const EdgeInsets.all(16.0), // Margen alrededor del mapa
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0), // Bordes redondeados
                  border: Border.all(
                    color: Colors.cyanAccent, // Borde fosforescente
                    width: 4.0, // Grosor del borde
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.4), // Sombra brillante
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _location,
                    zoom: 14.0, // Nivel de zoom del mapa
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                  },
                  markers: {
                    Marker(
                      markerId: MarkerId('invited-location'),
                      position: _location,
                      infoWindow: InfoWindow(title: 'Ubicación del Invitado'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
                    ),
                  },
                ),
              ),
      ),
    );
  }
}
