import 'package:flutter/material.dart';

class TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // From → To
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${ticket['from']} → ${ticket['to']}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${ticket['price']} pts",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // No Ticket
            Text("No Ticket: ${ticket['id'] ?? '-'}"),

            // Date & Expired
            Text("Date: ${ticket['date'] ?? '-'}"),
            Text("Expired: ${ticket['expired'] ?? '-'}"),

            // Status
            Text(
              "Status: ${ticket['status'] ?? 'unknown'}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: (ticket['status'] == 'active')
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
