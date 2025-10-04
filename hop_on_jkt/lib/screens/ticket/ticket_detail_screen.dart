import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color primaryColor = Color(0xFF1E4D6E);
const Color secondColor = Color.fromARGB(255, 123, 188, 241);
const Color backgroundColor = Color(0xFFF5F9FD);
const Color chipColor = Color(0xFFE0F7FA);

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
  String? userPhoto;

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
        debugPrint(" User data: ${snapshot.data()}");

        setState(() {
          userName = snapshot.data()?['name'] ?? "Nama pelanggan";
          userPhoto = snapshot.data()?['photoPath'] ?? "avatar_1";
        });
      }
    } catch (e) {
      debugPrint("Error load user data: $e");
    }
  }

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

    return avatarMap[avatarId] ?? {'emoji': '🙂', 'color': Colors.grey};
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Detail Tiket",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Ticket Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // User Info Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: secondColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: avatar['color'],
                            child: Text(
                              avatar['emoji'],
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName ?? "Loading...",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.confirmation_number_rounded,
                                    color: primaryColor,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "#${ticketId.substring(0, 8)}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Route Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: secondColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.route_rounded,
                            color: primaryColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "From",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      fromStation,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  color: primaryColor,
                                  size: 24,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "To",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      toStation,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
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

                  // Dashed Divider
                  CustomPaint(
                    size: const Size(double.infinity, 1),
                    painter: DashedLinePainter(),
                  ),

                  // QR Code Section
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          "Scan QR Code",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: secondColor.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 250.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dashed Divider
                  CustomPaint(
                    size: const Size(double.infinity, 1),
                    painter: DashedLinePainter(),
                  ),

                  // Info Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (createdTime != null)
                          _buildInfoRow(
                            icon: Icons.calendar_today_rounded,
                            label: "Tanggal Pemesanan",
                            value: _formatDateTime(createdTime),
                            color: Colors.blue,
                          ),
                        if (createdTime != null && expiryTime != null)
                          const SizedBox(height: 12),
                        if (expiryTime != null)
                          _buildInfoRow(
                            icon: Icons.access_time_rounded,
                            label: "Berlaku Hingga",
                            value: _formatDateTime(expiryTime),
                            color: Colors.red,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}

// Custom Painter untuk garis putus-putus
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}