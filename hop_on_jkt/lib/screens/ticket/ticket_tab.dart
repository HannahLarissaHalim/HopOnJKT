import 'package:flutter/material.dart';
import 'buy_ticket_screen.dart';
import 'order_history_screen.dart';

class TicketTab extends StatelessWidget {
  const TicketTab({super.key});

  @override
  Widget build(BuildContext context) {
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
        body: const TabBarView(
          children: [
            BuyTicketScreen(
              fromStation: "Jakarta",
              toStation: "Bandung",
              price: 120,
            ),
            OrderHistoryScreen(
              userId: "dummyUser123", 
            ),
          ],
        ),
      ),
    );
  }
}
