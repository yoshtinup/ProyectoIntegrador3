import 'package:flutter/material.dart';

class GuestListView extends StatelessWidget {
  final List<Map<String, String>> guests;

  const GuestListView({Key? key, required this.guests}) : super(key: key);

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
        child: guests.isEmpty
            ? Center(
                child: Text(
                  'No hay invitados registrados.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: guests.length,
                itemBuilder: (context, index) {
                  final guest = guests[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
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
                        guest['name']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Estado: ${guest['status']}',
                        style: TextStyle(
                          color: guest['status'] == 'Dentro'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
