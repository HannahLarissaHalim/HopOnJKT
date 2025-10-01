import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'providers/auth_provider.dart' as my_auth;
import 'providers/ticket_provider.dart';

// screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'widgets/bottom_navbar.dart';
import 'screens/profile/edit_profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => my_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HopOnJKT',
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: "Coolvetica"),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const BottomNavBar(),
          '/edit-profile': (context) => const EditProfilePage(),
        },
      ),
    );
  }
}

// Wrapperutk tentuin layar awal sesuai status login
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fb_auth.User?>(
      stream: fb_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // kalau user sudah login langsung ke home
        if (snapshot.hasData) {
          return const BottomNavBar();
        }

        // kalau belum login tampil login screen
        return const LoginScreen();
      },
    );
  }
}
