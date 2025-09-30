import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; 
import '../../providers/ticket_provider.dart';
import '../../widgets/bottom_navbar.dart';

class BuyTicketScreen extends StatefulWidget {
  final String fromStation;  // stasiun asal
  final String toStation;    // stasiun tujuan
  final int price;           // harga tiket (dalam poin)

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
  int userPoints = 0;  // saldo poin user
  String userPin = ""; // pin user (4 digit)

  @override
  void initState() {
    super.initState();
    _loadUserData(); // pas pertama kali buka halaman load saldo & pin user
  }

  // ambil saldo & pin user dari Firestore
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

    setState(() {
      userPoints = snapshot['points'] ?? 0; // ambil field points
      userPin = snapshot['pin'] ?? "";      // ambil field pin
    });
  }

  // konfirmasi PIN sebelum bayar
  Future<void> _confirmPayment() async {
    final pinController = TextEditingController();

    // tampilkan popup input pin
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter PIN"),
          content: TextField(
            controller: pinController,
            obscureText: true, // biar pin ga keliatan
            keyboardType: TextInputType.number,
            maxLength: 4,      // pin = 4 digit
            decoration: const InputDecoration(
              hintText: "4-digit PIN",
              counterText: "",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // batal
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // cek apakah input pin sama dengan pin user
                if (pinController.text == userPin) {
                  Navigator.pop(context, true);  // pin valid
                } else {
                  Navigator.pop(context, false); // pin salah
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    // kalau pin valid proses pembayaran
    if (result == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        // data tiket yang mau disimpan
        final ticketData = {
          'id': const Uuid().v4(),
          'fromStation': widget.fromStation,
          'toStation': widget.toStation,
          'price': widget.price,
          'userId': user.uid,
        };

        // panggil provider utk kurangi poin + simpan tiket 
        await Provider.of<TicketProvider>(context, listen: false).buyTicket(
          userId: user.uid,
          price: widget.price,
          ticketData: ticketData,
        );

        // reload saldo user setelah transaksi
        _loadUserData();

        // kasih notifikasi sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment Success ✅")),
        );

        // setelah sukses, pindah ke tab My Orders (OrderHistory)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const BottomNavBar(initialIndex: 1),
          ),
          (route) => false,
        );

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }

    } else {
      // kalau pin salah
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wrong PIN ❌")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // header atas
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Ticket",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A3C6E),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
            ),

            // kartu tiket (detail tiket + saldo user + tombol bayar)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // row info tiket
                  Row(
                    children: [
                      const Icon(Icons.train, size: 30, color: Colors.black87),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "${widget.fromStation} → ${widget.toStation}", // asal -> tujuan
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text("${widget.price} pts", // harga tiket
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          )),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // saldo user
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Your balance: $userPoints Points", // tampilkan saldo
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // tombol bayar
                  ElevatedButton(
                    onPressed: _confirmPayment, // kalau ditekan cek pin dulu
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3C6E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Pay with points"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ), 
    );
  }
}
