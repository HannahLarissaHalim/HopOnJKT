import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final _formKey = GlobalKey<FormState>(); // validasi form

  // controller utk perantara widget dan code
  // TextEditingController untuk ambil dan simpan input user dari TextField
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // password kelihatan gak, default = true (hidden)
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // dispose supaya gak memory leak
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // buat daftar akun
  Future<void> _handleSignUp() async {
   
    if (!_formKey.currentState!.validate()) return;     // cek validasi form, apakah semua field sdh valid

    final authProvider = context.read<AuthProvider>();  // ambil instance AuthProvider dari context  
    
    // panggil authProvider.signUp()
    // trim() hapus spasi 
    final success = await authProvider.signUp(
      _emailController.text.trim(),
      _passwordController.text,
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
    );

    // mounted itu boolean bawaan State, true berarti bs update UI dan kebalikannya
    if (success && mounted) {

      // kalau sukses pindah ke halaman login
      Navigator.pushReplacementNamed(context, '/login');

      // snackbar untuk popup kecil di bawah layar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registration failed'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // gada bayangan
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // tombol back
          onPressed: () => Navigator.pop(context), // kalau ditekan nanti back
        ),
      ),

      // body
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0), // semua padding
            child: Form(
              key: _formKey, // hubungkan form dengan validasi
              child: Column(
                children: [
                  // header text
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8), // spasi dikit
                  
                  // subtext
                  const Text(
                    'Join HopOnUK today',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32), // spasi lumayan
                  
                  // sign up form
                  // expanded sesuai layar
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16), // rounded corner
                      ),

                      // biar bisa discroll
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // first Name
                            CustomTextField(
                              controller: _firstNameController, // hubungkan controller
                              label: 'First Name',
                              prefixIcon: Icons.person_outlined,
                              validator: (value) {
                                 // validasi input
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your first name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // last name
                            CustomTextField(
                              controller: _lastNameController,
                              label: 'Last Name',
                              prefixIcon: Icons.person_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your last name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // email
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                // regex cek format email
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) { 
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // password
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Password',
                              obscureText: _obscurePassword, // true = disembunyikan (•••)
                              prefixIcon: Icons.lock_outlined,
                              suffixIcon: IconButton( // tombol show/hide password
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: AppColors.textMedium,
                                ),
                                onPressed: () {
                                  setState(() { // ubah state show/hide
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              )
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // confirm password
                            CustomTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              obscureText: _obscureConfirmPassword,
                              prefixIcon: Icons.lock_outlined,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                  color: AppColors.textMedium,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            
                            // tombol sign up
                            // listen state dari AuthProvider
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return LoadingButton(
                                  onPressed: _handleSignUp,
                                  isLoading: authProvider.isLoading,
                                  text: 'Create Account',
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // terms text
                            const Text(
                              'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMedium,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // sign in link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // balik ke login screen
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
                    
                        