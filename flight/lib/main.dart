import 'package:firebase_core/firebase_core.dart';
import 'package:flight/Pages/AddAirlinesPage.dart';
import 'package:flight/Pages/DashboardAdminPage.dart';
import 'package:flight/Pages/LoginPage.dart';
import 'package:flight/Pages/RegisterPage.dart';
import 'package:flight/firebase_options.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        // Memperbaiki pemanggilan HomePage dengan parameter email dan role
        '/home': (context) => HomePage(),
        '/addAirlines': (context) => AddAirlinesPage(),
        '/admindashboard': (context) => DashboardAdminPage(),
      },
    );
  }
}
