import 'package:flutter/material.dart';
import 'loginpage.dart';
import 'registerpage.dart';
import 'mapscreen.dart';
import 'location_tracking_page.dart';
import 'homepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Maps & Location',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/map': (context) => MapScreen(),
        '/location_tracking': (context) => const LocationTrackingPage(),
      },
    );
  }
}
