import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_history_screen.dart';
import '../journey/route_screen.dart';

class TicketTab extends StatelessWidget {
  const TicketTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // ✅ ambil user yg login
    final userId = user?.uid ?? ""; // kalau null = kosong

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Tickets"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Buy Ticket"),
              Tab(text: "My Orders"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RouteScreen(
              // user pilih rute dulu
              from: "Manggarai",
              to: "Jakarta Kota",
              date: DateTime.now(),
              departureTime: DateTime.now(),
            ),
            OrderHistoryScreen(
              userId: userId, // ✅ pakai user login
            ),
          ],
        ),
      ),
    );
  }
}
