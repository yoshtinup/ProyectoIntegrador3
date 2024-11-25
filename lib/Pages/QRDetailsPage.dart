import 'package:flutter/material.dart';


class QRDetailsPage extends StatelessWidget {
  final Map<String, dynamic> jsonData;

  const QRDetailsPage({Key? key, required this.jsonData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? imageUrl;
    Map<String, dynamic> otherData = {};

    // Separar imagen y otros datos
    jsonData.forEach((key, value) {
      if (value is String && 
          (value.endsWith('.png') || value.endsWith('.jpg') || value.endsWith('.jpeg'))) {
        imageUrl = value;
      } else {
        otherData[key] = value;
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black,
                  Color(0xFF1A1A1A),
                ],
              ),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/QR.png'),
                opacity: 0.03,
              ),
            ),
          ),
          // Contenido principal
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.cyanAccent.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Detalles del QR',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.cyanAccent.withOpacity(0.5),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (imageUrl != null)
                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.cyanAccent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFF2D2D2D),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, color: Colors.white70),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'No se pudo cargar la imagen',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                if (otherData.isNotEmpty)
                  ...otherData.entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.cyanAccent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {},
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.cyanAccent,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      entry.key.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.cyanAccent,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  entry.value.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                if (imageUrl == null && otherData.isEmpty)
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            color: Colors.white70,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No se encontraron datos en el contenido',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}