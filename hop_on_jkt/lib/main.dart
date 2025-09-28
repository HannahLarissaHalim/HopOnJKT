import 'package:flutter/material.dart';
import 'screens/journey/route_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journey Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: RouteScreen(
        from: 'Manggarai',
        to: 'Jakarta Kota',
        date: DateTime.now(),
      ),
      routes: {
        '/purchase': (context) => Scaffold(
          appBar: AppBar(title: Text('Purchase Ticket')),
          body: Center(child: Text('Pembelian tiket bisa narok kesini')),
        ),
        '/account': (context) => Scaffold(
          appBar: AppBar(title: const Text('Account Profile')),
          body: const Center(child: Text('Akun profil bisa narok disini')),
        ),
      },
    );
  }
}