import 'package:flutter/material.dart';

class RatePage extends StatelessWidget {
  const RatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rate This App"),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text(
          "Rate feature is coming soon!",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
