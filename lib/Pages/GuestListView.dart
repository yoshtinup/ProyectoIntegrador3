import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:integrador/Pages/map_screen.dart';
import 'dart:convert';


class GuestListView extends StatefulWidget {
  const GuestListView({Key? key}) : super(key: key);

  @override
  _GuestListViewState createState() => _GuestListViewState();
}

class _GuestListViewState extends State<GuestListView> {
  List<Map<String, dynamic>> guests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGuests();  // Llamada al API al iniciar la vista
  }

  // Función para obtener los invitados desde el endpoint
  Future<void> fetchGuests() async {
    try {
      final response = await http.get(Uri.parse('https://apipulserelastik.integrador.xyz/api/v1/boletos'));

      if (response.statusCode == 200) {
        // Si la respuesta es exitosa, parseamos el JSON
        List<dynamic> data = json.decode(response.body);
        setState(() {
          guests = data.map((e) => e as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        // Si la respuesta es diferente a 200, mostramos un error
        throw Exception('Error al cargar los invitados');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Invitados',
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())  // Muestra un loading mientras se cargan los datos
            : guests.isEmpty
                ? const Center(
                    child: Text(
                      'No hay invitados registrados.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: guests.length,
                    itemBuilder: (context, index) {
                      final guest = guests[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.cyanAccent, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            guest['evento'] ?? 'Sin nombre',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          subtitle: Text(
                            'Estado: ${guest['tipo'] ?? 'Desconocido'}',
                            style: TextStyle(
                              color: Colors.red, // Aquí puedes cambiar el color basado en el estado
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            // Navegar al MapScreen con el lugar (coordenadas)
                            final lugar = guest['lugar'];  // El campo lugar contiene las coordenadas
                            if (lugar != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapScreen(lugar: lugar),
                                ),
                              );
                            } else {
                              // Si no hay lugar, muestra un mensaje
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No hay ubicación disponible')),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
