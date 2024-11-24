import 'package:flutter/material.dart';
import 'GuestListView.dart';
import 'QRScanPage.dart';

class HomeAdminView extends StatefulWidget {
  @override
  _HomeAdminViewState createState() => _HomeAdminViewState();
}

class _HomeAdminViewState extends State<HomeAdminView> {
  List<Map<String, String>> guests = [];

  void _updateGuestList(Map<String, dynamic> guestData) {
    final String name = guestData['Nombre'] ?? 'Invitado desconocido';

    setState(() {
      final existingGuest = guests.firstWhere(
        (guest) => guest['name'] == name,
        orElse: () => {'name': name, 'status': 'Fuera'},
      );

      if (existingGuest['status'] == 'Fuera') {
        guests.remove(existingGuest);
        guests.add({'name': name, 'status': 'Dentro'});
      } else {
        guests.remove(existingGuest);
        guests.add({'name': name, 'status': 'Fuera'});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado negro con textura
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
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QRScanPage(onUpdateGuests: _updateGuestList),
                          ),
                        );
                      },
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
                        'Escanear QR',
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GuestListView(guests: guests),
                          ),
                        );
                      },
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
                        'Lista de Invitados',
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
}
