import 'package:flutter/material.dart';

class HomeUsuario extends StatelessWidget {
  const HomeUsuario({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Fondo degradado
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 600;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo QR con separación ajustada
                    Container(
                      margin: const EdgeInsets.only(bottom: 40),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.cyanAccent,
                          width: 4,
                        ),
                      ),
                      child: const Icon(
                        Icons.qr_code_2,
                        size: 100,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Bienvenido, Invitado',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Menú Principal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Botones principales
                    _buildResponsiveButton(
                      context,
                      icon: Icons.qr_code,
                      label: 'Ver QR',
                      onTap: () {
                        Navigator.pushNamed(context, '/miQR'); // Redirección
                      },
                      isSmallScreen: isSmallScreen,
                    ),
                    const SizedBox(height: 20),
                    _buildResponsiveButton(
                      context,
                      icon: Icons.event,
                      label: 'Ver eventos',
                      onTap: () {
                        Navigator.pushNamed(context, '/eventos'); // Redirección
                      },
                      isSmallScreen: isSmallScreen,
                    ),
                    const SizedBox(height: 20),
                    _buildResponsiveButton(
                      context,
                      icon: Icons.qr_code_scanner,
                      label: 'Generar QR',
                      onTap: () {
                      Navigator.pushNamed(context, '/userDashboard'); // Redirección
                      },
                      isSmallScreen: isSmallScreen,
                    ),
                    const Spacer(),
                    // Botón Cerrar sesión
                    _buildLogoutButton(
                      context,
                      label: 'Cerrar sesión',
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    final double buttonHeight = isSmallScreen ? 60 : 70; // Altura del botón
    final double buttonWidth = isSmallScreen ? 250 : 300; // Anchura del botón
    final double fontSize = isSmallScreen ? 16 : 18; // Tamaño de fuente

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: buttonHeight,
        width: buttonWidth,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.cyanAccent, width: 2),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context,
      {required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 40, // Tamaño fijo para el botón de cerrar sesión
        width: 150,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.redAccent, width: 2),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
