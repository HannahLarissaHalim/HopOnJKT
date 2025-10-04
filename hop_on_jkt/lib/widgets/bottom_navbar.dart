import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/journey/route_screen.dart';
import '../screens/ticket/order_history_screen.dart';
import '../screens/profile/profile_page.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex; //  untuk masuk langsung ke tab tertentu
  final bool showPaymentSuccess;

  const BottomNavBar({
    super.key,
    this.initialIndex = 0,
    this.showPaymentSuccess = false, // default false
  }); 

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; //supaya bisa start dari tab ke-2

  WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showPaymentSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment Successful :D"),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  // final List<Widget> _screens = [
  //   RouteScreen(from: "Manggarai", to: "Jakarta Kota", date: DateTime.now()),
  //   OrderHistoryScreen(userId: "dummyUserId"),
  //   Center(child: Text("Account Page (soon)")),
  // ];

  @override
  Widget build(BuildContext context) {
    // ambil userId dari FirebaseAuth
    final userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    // screens yang dipakai IndexedStack
    final List<Widget> _screens = [
      RouteScreen(from: "Manggarai", to: "Jakarta Kota", date: DateTime.now()),
      OrderHistoryScreen(userId: userId),
      ProfilePage(), // <-- ganti dari "soon" ke ProfilePage
    ];

    return Scaffold(
      body: IndexedStack(
        // supaya state tiap screen ga reset
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),

        backgroundColor: const Color(0xFFF2F6F9), 
        selectedItemColor: const Color(0xFF1687E3), 
        unselectedItemColor: Colors.grey, 

        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 8,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num),
            label: "Tickets",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}
