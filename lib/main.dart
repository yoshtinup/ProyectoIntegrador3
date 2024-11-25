import 'package:flutter/material.dart';
import 'package:integrador/Pages/Register_User.dart';
import 'package:integrador/Pages/home_admin.dart';
import 'package:integrador/Pages/home_page.dart';
import 'package:integrador/Pages/home_user.dart'; // Importa el archivo correctamente
import 'package:integrador/Pages/Home_usuario.dart';
import 'Pages/QRScanPage.dart';
import 'pages/user_view.dart';
import 'pages/admin_view.dart';
import 'Pages/Logoview.dart';
import 'Pages/MiQR.dart';
import 'Pages/Grafica_screen.dart';
import 'package:integrador/Pages/eventos_screen.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Service',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/logoView', // Cambiar aquí la ruta inicial si es necesario
      routes: {
        '/': (context) => HomePage(),
        '/user': (context) => UserView(),
        '/admin': (context) => AdminView(),
        '/register': (context) => RegisterView(),
        '/homeUsuario': (context) => HomeUsuario(),
        '/miQR': (context) => MiQR(),
        '/homeAdmin': (context) => HomeAdminView(),
        '/eventos': (context) => EventosScreen(),
        '/grafica': (context) => const GraficaScreen(), 
        '/qrscan': (context) => QRScanPage(
              onUpdateGuests: (Map<String, dynamic> guestData) {
                print('Datos del invitado: $guestData');
              },
            ),
        '/logoView': (context) => LogoView(),
        '/userDashboard': (context) => UserDashboardView(), // Asociar correctamente la ruta a la vista
      },
    );
  }
}
