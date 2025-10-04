import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:provider/provider.dart';
import 'package:get/get.dart';

// Providers
import 'providers/auth_provider.dart' as my_auth;
import 'providers/ticket_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'widgets/bottom_navbar.dart';
import 'screens/profile/edit_profile_page.dart';
import 'screens/auth/welcome_screen.dart';

// Alias untuk screens yang bentrok
import 'screens/profile/change_pin_screen.dart' as pin_screen;
import 'screens/profile/change_password_screen.dart' as pass_screen;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Kalau mau testing tanpa login, bisa pakai ini:
  // await fb_auth.FirebaseAuth.instance.signOut();

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
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: "Coolvetica",
        ),
        home: const AuthWrapper(),
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const BottomNavBar(),
          '/edit-profile': (context) => const EditProfilePage(),
          '/change-pin': (context) => const pin_screen.ChangePinScreen(),
          '/change-password': (context) =>
              const pass_screen.ChangePasswordScreen(),
        },
      ),
    );
  }
}

// Wrapper untuk tentuin layar awal sesuai status login
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider =
        Provider.of<my_auth.AuthProvider>(context, listen: false);
    await authProvider.checkAuthState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fb_auth.User?>(
      stream: fb_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Kalau masih loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Kalau sudah login
        if (snapshot.hasData) {
          return FutureBuilder(
            future: _loadUserFromFirestore(),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return const BottomNavBar();
            },
          );
        }

        // Kalau belum login
        return const WelcomeScreen();
      },
    );
  }

  Future<void> _loadUserFromFirestore() async {
    final authProvider =
        Provider.of<my_auth.AuthProvider>(context, listen: false);
    await authProvider.checkAuthState();
  }
}
