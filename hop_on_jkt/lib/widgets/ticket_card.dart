import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ biar format tanggal rapi

class TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    // parsing field tanggal
    String depart = ticket['departureTime'] != null
        ? DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(ticket['departureTime']))
        : "-";

    String arrive = ticket['arrivalTime'] != null
        ? DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(ticket['arrivalTime']))
        : "-";

    String expired = ticket['expiryTime'] != null
        ? DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(ticket['expiryTime']))
        : "-";

    String duration = ticket['duration'] != null
        ? "${ticket['duration']} min"
        : "-";

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

            // Depart & Arrival
            Text("Depart: $depart"),
            Text("Arrive: $arrive"),

            // Duration
            Text("Duration: $duration"),

            // Expired
            Text("Expired: $expired"),

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
