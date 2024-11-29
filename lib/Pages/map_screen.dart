import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  final String lugar; // Ubicación del usuario (como 'lat, lon')

  const MapScreen({Key? key, required this.lugar}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _controller;
  late LatLng _userLocation;
  late LatLng _myLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _parseLocation();
    _getCurrentLocation();
  }

  // Parsear la ubicación del usuario
  void _parseLocation() {
    final coords = widget.lugar.split(', ');
    final lat = double.parse(coords[0]);
    final lon = double.parse(coords[1]);
    setState(() {
      _userLocation = LatLng(lat, lon);
    });
  }

  // Obtener la ubicación actual del dispositivo
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _myLocation = LatLng(position.latitude, position.longitude);
    });
    _addMarkers();
  }

  // Agregar los marcadores de origen y destino
  void _addMarkers() {
    setState(() {
      // Marcador para la ubicación del dispositivo (origen)
      _markers.add(Marker(
        markerId: MarkerId('my-location'),
        position: _myLocation,
        infoWindow: InfoWindow(title: 'Mi Ubicación'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));

      // Marcador para la ubicación del usuario (destino)
      _markers.add(Marker(
        markerId: MarkerId('user-location'),
        position: _userLocation,
        infoWindow: InfoWindow(title: 'Ubicación del Invitado'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        onTap: _onUserLocationTap, // Tocar este marcador para trazar la ruta
      ));
    });
  }

  // Función llamada al tocar el marcador del usuario para trazar la ruta
  Future<void> _onUserLocationTap() async {
    await _getRoute(); // Trazar la ruta entre las ubicaciones (origen y destino)
  }

  // Obtener la ruta entre la ubicación actual (origen) y la ubicación del usuario (destino)
  Future<void> _getRoute() async {
    final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${_myLocation.latitude},${_myLocation.longitude}&destination=${_userLocation.latitude},${_userLocation.longitude}&key=YOUR_GOOGLE_MAPS_API_KEY';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final route = data['routes'][0]['legs'][0]['steps'];

      List<LatLng> polylinePoints = [];
      for (var step in route) {
        final lat = step['end_location']['lat'];
        final lon = step['end_location']['lng'];
        polylinePoints.add(LatLng(lat, lon));
      }

      setState(() {
        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: polylinePoints,
          color: Colors.blue,
          width: 5,
        ));
      });
    } else {
      // Manejo de errores si la respuesta de la API no es exitosa
      print("Error al obtener la ruta: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        child: _myLocation == null || _userLocation == null
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
                    target: _myLocation,
                    zoom: 14.0, // Nivel de zoom del mapa
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                  },
                  markers: _markers,
                  polylines: _polylines,
                ),
              ),
      ),
    );
  }
}
