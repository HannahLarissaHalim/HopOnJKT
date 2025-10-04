import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback? onTap; // biar bisa diklik

  const TicketCard({super.key, required this.ticket, this.onTap});

  @override
  Widget build(BuildContext context) {
    final expiry = ticket['expiryTime'];
    String expiryText = "-";

    if (expiry != null) {
      DateTime expiryTime;
      if (expiry is Timestamp) {
        expiryTime = expiry.toDate();
      } else if (expiry is String) {
        expiryTime = DateTime.tryParse(expiry) ?? DateTime.now();
      } else {
        expiryTime = DateTime.now();
      }
      expiryText = DateFormat("dd MMM yyyy, HH:mm").format(expiryTime);
    }

    String createdText = "-";
    final created = ticket['date'];
    if (created != null) {
      DateTime createdTime;
      if (created is Timestamp) {
        createdTime = created.toDate();
      } else if (created is String) {
        createdTime = DateTime.tryParse(created) ?? DateTime.now();
      } else {
        createdTime = DateTime.now();
      }
      createdText = DateFormat("dd MMM yyyy, HH:mm").format(createdTime);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        color: const Color(0xFFF3F4F6),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FromStation → ToStation + Price
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
              Text("Date: $createdText"),
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
      ),
    );
  }
}
