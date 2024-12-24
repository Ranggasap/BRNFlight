import 'package:firebase_core/firebase_core.dart';
import 'package:flight/Pages/AddAirlinesPage.dart';
import 'package:flight/Pages/DashboardAdminPage.dart';
import 'package:flight/Pages/LoginPage.dart';
import 'package:flight/Pages/RegisterPage.dart';
import 'package:flight/Pages/TemporaryPages/HomePage.dart';
import 'package:flight/firebase_options.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(BRNFlightApp());
}

class BRNFlightApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (centext) => HomePage(),
        '/addAirlines': (ccontext) => AddAirlinesPage(),
        '/admindashboard': (context) => DashboardAdminPage()
      },
    );
  }
}
