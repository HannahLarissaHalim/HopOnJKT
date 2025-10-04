import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../providers/ticket_provider.dart';
import 'ticket_detail_screen.dart';

class BuyTicketScreen extends StatefulWidget {
  final String fromStation; // stasiun asal
  final String toStation; // stasiun tujuan
  final int price; // harga tiket (dalam poin)

  const BuyTicketScreen({
    Key? key,
    required this.fromStation,
    required this.toStation,
    required this.price,
  }) : super(key: key);

  @override
  State<BuyTicketScreen> createState() => _BuyTicketScreenState();
}

class _BuyTicketScreenState extends State<BuyTicketScreen> {
  int userPoints = 0; // saldo poin user
  String userPin = ""; // pin user

  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // pas pertama kali buka halaman load saldo & pin user
  }

  // ambil saldo & pin user dari Firestore
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    setState(() {
      userPoints = snapshot['points'] ?? 0;
      userPin = (snapshot['pin'] ?? "").toString();
    });
  }

  // konfirmasi PIN sebelum bayar
  Future<void> _confirmPayment() async {
    final pinController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Enter PIN"),
              content: TextField(
                controller: pinController,
                obscureText: _isObscure,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: "Enter 6-digit PIN",
                  counterText: "",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (pinController.text == userPin) {
                      Navigator.pop(context, true);
                    } else {
                      Navigator.pop(context, false);
                    }
                  },
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final ticketData = {
          'id': const Uuid().v4(),
          'fromStation': widget.fromStation,
          'toStation': widget.toStation,
          'price': widget.price,
          'userId': user.uid,
          'status': 'active',
          'date': Timestamp.fromDate(DateTime.now()),
          'expiryTime': Timestamp.fromDate(
            DateTime.now().add(const Duration(minutes: 120)),
          ),
          'qrData': "TICKET-${user.uid}-${DateTime.now().millisecondsSinceEpoch}",
        };

        // simpan tiket + kurangi poin
        await Provider.of<TicketProvider>(context, listen: false).buyTicket(
          userId: user.uid,
          price: widget.price,
          ticketData: ticketData,
        );

        _loadUserData();

        // langsung ke TicketDetailScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TicketDetailScreen(ticket: ticketData),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wrong PIN :()")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "TICKET PAYMENT",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A3C6E),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 224, 240, 255),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.train, size: 28, color: Colors.black87),
                          const SizedBox(width: 8),
                          Text(
                            "${widget.fromStation} → ${widget.toStation}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Price: ${widget.price} pts",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDF3A1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Your points: $userPoints",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF4C8912),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _confirmPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3C6E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        "Pay with points",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
