import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // controller untuk ambil teks dari input field
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final pinController = TextEditingController();

  // loading state biar tombol bisa nunjukin spinner loading
  bool isLoading = false;

  // password/pin keliatan atau gak
  bool _obscurePassword = true;
  bool _obscurePin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        // stack biar bisa layering background, clouds, form, kereta
        children: [
          // background scr keseluruhan
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE6F9F5), Color(0xFFF9FFFF)],
              ),
            ),
          ),

          // gambar awan
          // biar gak tabrakan sama status bar/baterai pake SafeArea
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                "assets/images/clouds.png",
                fit: BoxFit.cover,
                width: double.infinity,
                height: 160,
              ),
            ),
          ),

          // HopOnJKT
          Align(
            alignment: Alignment.topCenter,

            child: Padding(
              padding: const EdgeInsets.only(
                top:
                    120, // jarak dari atas layar, biar teks agak ke bawah dan gak nempel sama awan
              ),

              child: const Text(
                "HopOnJKT",
                style: TextStyle(
                  fontFamily: "HeyComic",
                  fontSize: 55,
                  color: Color(0xFF1A3C6E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // form sign up
          // center supaya semua yg didalam form selalu di tengah
          Center(
            // biar bisa scroll kalo layar kecil
            child: SingleChildScrollView(
              // jarak 20 px kiri & kanan
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Container(
                padding: const EdgeInsets.all(20), // ruang di dalam form

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black, blurRadius: 7)],
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // input email
                    TextField(
                      controller: emailController, // ambil input teks email
                      decoration: InputDecoration(
                        hintText: "Email",
                        filled: true,
                        fillColor: Colors.grey[200], // background abu-abu muda
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide.none, // hilangkan border hitam default
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // input pw
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword, // default true
                      decoration: InputDecoration(
                        hintText: "Password",
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF1A3C6E),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // input pin
                    TextField(
                      controller: pinController,
                      obscureText: _obscurePin, // default true
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        hintText: "Set 6-digit PIN",
                        counterText: "",
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePin
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF1A3C6E),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePin = !_obscurePin;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tombol Sign Up
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(
                                () => isLoading =
                                    true, // disable kalau lagi loading
                              );
                              try {
                                // panggil provider untuk signup ke firebase
                                // dgn cara akses AuthProvider untuk panggil fungsi signUp lalu kirim data dari TextField
                                await Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                ).signUp(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                  pinController.text.trim(),
                                );

                                // kalau sukses kasih snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Sign Up Success"),
                                  ),
                                );
                                // pindah ke halaman home
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/home',
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e")),
                                );
                              } finally {
                                setState(
                                  () =>
                                      isLoading = false, // tombol bisa ditekan,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3C6E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            ) // spinner loading putih
                          : const Text("Sign Up"), // teks "Sign Up"
                    ),
                  ],
                ),
              ),
            ),
          ),

          // kereta
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              "assets/images/kereta.png",
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}
