import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/bottom_navbar.dart';

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
      userPoints = snapshot['points'] ?? 0; // ambil field points
      userPin = (snapshot['pin'] ?? "").toString(); // ambil field pin
    });
  }

  // konfirmasi PIN sebelum bayar
  Future<void> _confirmPayment() async {
    final pinController = TextEditingController();

    // tampilkan popup input pin
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // biar bisa setState di dalam dialog
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Enter PIN"),
              content: TextField(
                controller: pinController,
                obscureText: _isObscure, // pakai state untuk hide/show
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
                        _isObscure = !_isObscure; // toggle
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
          'status': 'active',
          'date': FieldValue.serverTimestamp(),
          'expiryTime': Timestamp.fromDate(
            DateTime.now().add(const Duration(minutes: 120)),
          ),
        };

        // panggil provider utk kurangi poin + simpan tiket
        await Provider.of<TicketProvider>(context, listen: false).buyTicket(
          userId: user.uid,
          price: widget.price,
          ticketData: ticketData,
        );

        // reload saldo user setelah transaksi
        _loadUserData();

        // // kasih notifikasi sukses
        // ScaffoldMessenger.of(
        //   context,
        // ).showSnackBar(const SnackBar(content: Text("Payment Successful :D")));

        // Future.delayed(const Duration(milliseconds: 300), () {
        //   Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(
        //       builder: (_) => const BottomNavBar(initialIndex: 1),
        //     ),
        //     (route) => false,
        //   );
        // });

        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("Payment Successful :D")),
        // );

        // await Future.delayed(const Duration(seconds: 1));
        // if (!mounted) return;

        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => const BottomNavBar(initialIndex: 1),
        //   ),
        //   (route) => false,
        // );

        Future.delayed(const Duration(milliseconds: 200), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const BottomNavBar(initialIndex: 1, showPaymentSuccess: true),
            ),
            (route) => false,
          );
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Wrong PIN :()")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Stack(
            clipBehavior: Clip.none, 
            children: [
              // CARD PUTIH
              Container(
                margin: const EdgeInsets.all(20),
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
                    const SizedBox(height: 30), // space bawah header

                    // RUTE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.train, size: 28, color: Colors.black87),
                        const SizedBox(width: 8),
                        Text(
                          "${widget.fromStation} → ${widget.toStation}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on,
                            size: 22, color: Colors.black54),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // PRICE
                    Text(
                      "price: ${widget.price} pts",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red, // 🔹 merah
                      ),
                    ),

                    const SizedBox(height: 20),

                    // BALANCE BOX
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDF3A1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Your points: $userPoints",
                        style: const TextStyle(
                          color: Color(0xFF4C8912),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // BUTTON
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // HEADER DI LUAR CARD 
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3C6E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "TICKET PAYMENT", 
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}