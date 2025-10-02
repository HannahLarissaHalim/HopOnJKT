import 'package:flutter/material.dart';

class PointsPage extends StatelessWidget {
  const PointsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Points"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Points feature is coming soon!",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // nanti bisa diisi top-up action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Top-up feature coming soon!")),
                );
              },
              child: const Text("Top-up Points"),
            ),
          ],
        ),
      ),
    );
  }
}
