import 'package:flutter/material.dart';

// Vista principal del administrador
class HomeAdminView extends StatelessWidget {
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3), width: 1),
                      ),
                      child: const Text(
                        'Bienvenido, Administrador',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent,
                          shadows: [
                            Shadow(
                              color: Colors.cyanAccent,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Opciones Administrativas',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    _buildListTile(
                      context,
                      icon: Icons.people,
                      title: 'Lista de Invitados',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GuestListView()),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildListTile(
                      context,
                      icon: Icons.event,
                      title: 'Ver Eventos',
                      onTap: () {
                        Navigator.pushNamed(context, '/events');
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildListTile(
                      context,
                      icon: Icons.qr_code_scanner,
                      title: 'Escanear QR',
                      onTap: () {
                        Navigator.pushNamed(context, '/qrscan');
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildListTile(
                      context,
                      icon: Icons.settings,
                      title: 'Configuraciones',
                      onTap: () {
                        Navigator.pushNamed(context, '/settings');
                      },
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

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        backgroundColor: Colors.black.withOpacity(0.8),
        side: const BorderSide(color: Colors.cyanAccent, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Colors.cyanAccent.withOpacity(0.3),
        elevation: 10,
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class GuestListView extends StatelessWidget {
  final List<String> guests = ["Juan Pérez", "Maria López", "Carlos Díaz"]; // Ejemplo de datos de invitados

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
        child: ListView.builder(
          itemCount: guests.length,
          itemBuilder: (context, index) {
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
                  guests[index],
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${guests[index]} ha entrado')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${guests[index]} ha salido')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
