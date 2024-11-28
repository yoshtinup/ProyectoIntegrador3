import 'package:flutter/material.dart';
import 'GuestListView.dart';
import 'QRScanPage.dart';
import 'Grafica_screen.dart';

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

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 250, // Ancho común para los botones principales
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          side: const BorderSide(color: Colors.cyanAccent, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          shadowColor: Colors.cyanAccent.withOpacity(0.3),
          elevation: 10,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 150, // Más pequeño que los botones principales
      height: 40, // Altura reducida
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          side: const BorderSide(color: Colors.redAccent, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          shadowColor: Colors.redAccent.withOpacity(0.5),
          elevation: 10,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14, // Letra más pequeña para el botón
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita cerrar la ventana tocando fuera
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black, // Fondo negro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.cyanAccent, width: 3),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '¿Estás seguro que quieres cerrar sesión?',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Cierra la ventana
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        side: const BorderSide(color: Colors.redAccent, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'NO',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Cierra la ventana
                        Navigator.pop(context); // Simula cerrar sesión
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        side: const BorderSide(color: Colors.cyanAccent, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'SÍ',
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
                image: AssetImage('assets/Logo.png'),
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
                    // Botones principales
                    _buildButton(
                      label: 'Escanear QR',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QRScanPage(onUpdateGuests: _updateGuestList),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildButton(
                      label: 'Lista de Invitados',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const  GuestListView() ,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildButton(
                      label: 'Gráfico de Ventas',
                      onPressed: () {
                        Navigator.pushNamed(context, '/grafica');
                      },
                    ),
                    const SizedBox(height: 30),
                    // Botón de Cerrar Sesión
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildLogoutButton(
                        label: 'Cerrar Sesión',
                        onPressed: () {
                          _showLogoutConfirmationDialog(context);
                        },
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
