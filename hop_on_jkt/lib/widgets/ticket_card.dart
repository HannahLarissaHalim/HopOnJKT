import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
   
    DateTime? expiryTime;
    if (ticket['expiryTime'] != null) {
      try {
        expiryTime = DateTime.tryParse(ticket['expiryTime'].toString());
      } catch (e) {
        expiryTime = null;
      }
    }

    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final expiryText = expiryTime != null ? dateFormat.format(expiryTime) : "-";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FromStation → ToStation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${ticket['fromStation'] ?? '-'} → ${ticket['toStation'] ?? '-'}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${ticket['price'] ?? 0} pts",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Ticket ID
            Text("No Ticket: ${ticket['id'] ?? '-'}"),

            // Date & Expired
            Text("Date: ${ticket['departureTime'] ?? '-'}"), 
            Text("Expired: $expiryText"), 

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
