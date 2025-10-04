// lib/screens/tickets/ticket_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TicketDetailScreen extends StatefulWidget {
  final Map<String, dynamic> ticket;

  const TicketDetailScreen({
    Key? key,
    required this.ticket,
  }) : super(key: key);

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  String? userName;
  String? userPhoto; // avatar ID (misal: avatar_2)

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = widget.ticket['userId'];
      if (userId == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();

      if (snapshot.exists) {
        debugPrint("🔥 User data: ${snapshot.data()}");

        setState(() {
          userName = snapshot.data()?['name'] ?? "Nama pelanggan";
          userPhoto = snapshot.data()?['photoPath'] ?? "avatar_1"; // default
        });
      }
    } catch (e) {
      debugPrint("Error load user data: $e");
    }
  }

  // Mapping avatar ID ke emoji & warna
  Map<String, dynamic> _getAvatar(String? avatarId) {
    const avatarMap = {
      'avatar_1': {'emoji': '😀', 'color': Colors.blue},
      'avatar_2': {'emoji': '😎', 'color': Colors.orange},
      'avatar_3': {'emoji': '🥳', 'color': Colors.purple},
      'avatar_4': {'emoji': '😇', 'color': Colors.green},
      'avatar_5': {'emoji': '🤩', 'color': Colors.pink},
      'avatar_6': {'emoji': '🤗', 'color': Colors.teal},
      'avatar_7': {'emoji': '😊', 'color': Colors.amber},
      'avatar_8': {'emoji': '🙂', 'color': Colors.indigo},
      'avatar_9': {'emoji': '😃', 'color': Colors.red},
      'avatar_10': {'emoji': '🤔', 'color': Colors.cyan},
      'avatar_11': {'emoji': '😺', 'color': Colors.deepOrange},
      'avatar_12': {'emoji': '🐶', 'color': Colors.brown},
    };

    return avatarMap[avatarId] ??
        {'emoji': '🙂', 'color': Colors.grey}; // fallback
  }

  @override
  Widget build(BuildContext context) {
    final String ticketId = widget.ticket['id'] ?? "N/A";
    final String fromStation = widget.ticket['fromStation'] ?? "-";
    final String toStation = widget.ticket['toStation'] ?? "-";
    final String qrData = widget.ticket['qrData'] ?? "";

    final expiry = widget.ticket['expiryTime'];
    final orderDate = widget.ticket['date'];

    DateTime? expiryTime;
    DateTime? createdTime;

    if (expiry != null) {
      if (expiry is Timestamp) {
        expiryTime = expiry.toDate();
      } else if (expiry is DateTime) {
        expiryTime = expiry;
      }
    }

    if (orderDate != null) {
      if (orderDate is Timestamp) {
        createdTime = orderDate.toDate();
      } else if (orderDate is DateTime) {
        createdTime = orderDate;
      }
    }

    final avatar = _getAvatar(userPhoto);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Back button + Title
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    const Text(
                      "My Tickets",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              // Ticket card
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Bagian atas tiket
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "No Ticket: $ticketId",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: avatar['color'],
                                child: Text(
                                  avatar['emoji'],
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName ?? "Nama pelanggan",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "$fromStation → $toStation",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: Colors.grey, thickness: 1),

                    // QR Code
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 30, bottom: 20), // lebih ke bawah
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 220.0,
                      ),
                    ),

                    // Bagian bawah tiket
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (createdTime != null)
                            Text(
                              "Tanggal pemesanan: ${createdTime.toString().substring(0, 16)}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          if (expiryTime != null)
                            Text(
                              "Waktu expired: ${expiryTime.toString().substring(0, 16)}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
