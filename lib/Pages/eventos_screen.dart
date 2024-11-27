import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EventosScreen(),
    );
  }
}

class EventosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Eventos Próximos',
          style: TextStyle(color: Colors.tealAccent),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              EventoCard(
                lugar: 'Palacio de los Deportes CDMX',
                fecha: '15/DIC/2024',
                artista: 'Wos',
                imagenPath: 'assets/Wos.jpg',
                url: 'https://www.ticketmaster.com.mx/wos-boletos/artist/2826671',
              ),
              SizedBox(height: 20),
              EventoCard(
                lugar: 'Pepsi Center, CDMX',
                fecha: '15/DIC/2024',
                artista: 'Paulo Londra',
                imagenPath: 'assets/Paulo.jpg',
                url: 'https://www.ticketmaster.com.mx/paulo-londra-boletos/artist/2640843',
              ),
              SizedBox(height: 20),
              EventoCard(
                lugar: 'Auditorio GNP Seguros',
                fecha: '15/SEP/2025',
                artista: 'Duki',
                imagenPath: 'assets/Duki.jpg',
                url: 'https://www.ticketmaster.com.mx/duki-boletos/artist/2627891',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventoCard extends StatefulWidget {
  final String lugar;
  final String fecha;
  final String artista;
  final String imagenPath;
  final String url;

  const EventoCard({
    required this.lugar,
    required this.fecha,
    required this.artista,
    required this.imagenPath,
    required this.url,
  });

  @override
  _EventoCardState createState() => _EventoCardState();
}

class _EventoCardState extends State<EventoCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAsistirPressed() async {
    await _controller.forward();
    await _controller.reverse();

    if (await canLaunchUrl(Uri.parse(widget.url))) {
      await launchUrl(Uri.parse(widget.url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir el enlace para ${widget.artista}.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.tealAccent),
      ),
      child: Column(
        children: [
          Image.asset(
            widget.imagenPath,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  widget.lugar,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  widget.fecha,
                  style: TextStyle(color: Colors.tealAccent, fontSize: 14),
                ),
                SizedBox(height: 10),
                Text(
                  widget.artista,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: ElevatedButton(
                    onPressed: _onAsistirPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Asistir'),
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

