import 'package:flutter/material.dart';

// Vista principal del administrador
class HomeAdminView extends StatelessWidget {
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Bienvenido, Administrador',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Opciones Administrativas',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
                      // Acción de escanear QR
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
        backgroundColor: Colors.black,
        side: const BorderSide(color: Colors.cyanAccent, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Vista de lista de invitados
class GuestListView extends StatelessWidget {
  final List<String> guests = ["Juan Pérez", "Maria López", "Carlos Díaz"]; // Ejemplo de datos de invitados

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Invitados'),
        backgroundColor: Colors.black,
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
            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(
                  guests[index],
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () {
                        // Acción para el botón "Entró"
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${guests[index]} ha entrado')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {
                        // Acción para el botón "Salió"
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
