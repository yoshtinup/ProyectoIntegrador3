import 'package:flutter/material.dart';
import 'package:integrador/Pages/Register_User.dart';
import 'package:integrador/Pages/home_admin.dart';
import 'package:integrador/Pages/home_page.dart';
import 'package:integrador/Pages/home_user.dart';
import 'Pages/QRScanPage.dart';
import 'pages/user_view.dart';
import 'pages/admin_view.dart';
import 'Pages/Logoview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Navigation Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/logoView', // Cambiar aquí la ruta inicial
      routes: {
        '/': (context) => HomePage(),
        '/user': (context) => UserView(),
        '/admin': (context) => AdminView(),
        '/register': (context) => RegisterView(),
        '/userDashboard': (context) => UserDashboardView(),
        '/homeAdmin': (context) => HomeAdminView(),
        '/qrscan': (context) => QRScanPage(
              onUpdateGuests: (Map<String, dynamic> guestData) {
                // Lógica para procesar la actualización de invitados
                print('Datos del invitado: $guestData');
              },
            ), // Agregar el parámetro requerido
        '/logoView': (context) => LogoView(), // Nueva ruta de la vista con el logo
      },
    );
  }
}
