import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>(); // key untuk validasi Form

  // controller2
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // fungsi login
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;     // validasi form

    final authProvider = context.read<AuthProvider>();  // ambil AuthProvider dari context
    
    // panggil fungsi signIn dari AuthProvider
    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    // kalau login sukses dan widget masih aktif
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) { // kalau gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(      // form untuk validasi input email & password
              key: _formKey,  // hubungkan dengan formKey
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(), // spacer utk dorong konten ke bawah
                  
                  // logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.train,
                      size: 40,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // title
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Sign in to your account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // login form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // email field
                        CustomTextField(
                          controller: _emailController, // controller email
                          label: 'Email Address',       // label input
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          // validasi input
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Password Field
                        CustomTextField(
                          controller: _passwordController,  // controller password
                          label: 'Password',
                          obscureText: _obscurePassword,    // true jadinya sembunyikan teks
                          prefixIcon: Icons.lock_outlined,
                          suffixIcon: IconButton(           // tombol toggle show/hide password
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: AppColors.textMedium,
                            ),
                            onPressed: () {
                              // ubah state show/hide
                              setState(() { 
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          // validasi password
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // login button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return LoadingButton(
                              onPressed: _handleLogin,
                              isLoading: authProvider.isLoading,
                              text: 'Sign In',
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // forgot password
                        TextButton(
                          onPressed: () {
                            _showForgotPasswordDialog();
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(), // dorong link sign up ke bawah layar
                  
                  // sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Don\'t have an account? ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup'); // pindah ke halaman sign up
                        },
                        child: const Text(
                          'Sign Up',
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

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email address to receive a password reset link.'),
              const SizedBox(height: 16),
              CustomTextField(
                controller: emailController,
                label: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return TextButton(
                  onPressed: authProvider.isLoading ? null : () async {
                    if (emailController.text.trim().isNotEmpty) {
                      final success = await authProvider.resetPassword(
                        emailController.text.trim(),
                      );
                      
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success 
                                ? 'Password reset email sent!' 
                                : authProvider.errorMessage ?? 'Failed to send reset email'
                            ),
                            backgroundColor: success ? AppColors.successGreen : AppColors.dangerRed,
                          ),
                        );
                      }
                    }
                  },
                  child: authProvider.isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}