// lib/screens/profile/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../providers/auth_provider.dart' as my_auth;

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _verified = false; // menandai apakah password lama sudah diverifikasi

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyOldPassword() async {
    final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
    final fb_auth.User? user = fb_auth.FirebaseAuth.instance.currentUser;
    final oldPass = _oldPasswordController.text.trim();

    if (oldPass.isEmpty) {
      _showError("Please enter your old password");
      return;
    }

    try {
      final email = authProvider.user?.email ?? "";
      final cred = fb_auth.EmailAuthProvider.credential(email: email, password: oldPass);
      await user?.reauthenticateWithCredential(cred);
      setState(() => _verified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Old password verified"), backgroundColor: Colors.green),
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      String msg = e.message ?? "Verification failed";
      if (e.code == 'wrong-password') msg = "Old password is incorrect";
      _showError(msg);
    }
  }

  Future<void> _changePassword() async {
    final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
    final fb_auth.User? user = fb_auth.FirebaseAuth.instance.currentUser;

    if (!_verified) {
      _showError("Please verify your old password first");
      return;
    }

    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      _showError("All fields are required");
      return;
    }
    if (newPass.length < 6) {
      _showError("New password must be at least 6 characters");
      return;
    }
    if (newPass != confirmPass) {
      _showError("New password and confirmation do not match");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await user?.updatePassword(newPass);
      await authProvider.checkAuthState();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password changed successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError("Failed to change password: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password"), centerTitle: true, backgroundColor: Colors.purple),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock, size: 80, color: Colors.purple),
            const SizedBox(height: 20),
            Text(
              _verified ? "Set New Password" : "Verify Your Old Password",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (!_verified)
              Column(
                children: [
                  _passwordField(
                    label: "Old Password",
                    controller: _oldPasswordController,
                    obscure: _obscureOld,
                    onToggle: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _verifyOldPassword,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                      child: const Text("Verify Old Password"),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _passwordField(
                    label: "New Password",
                    controller: _newPasswordController,
                    obscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  const SizedBox(height: 12),
                  _passwordField(
                    label: "Confirm New Password",
                    controller: _confirmPasswordController,
                    obscure: _obscureConfirm,
                    onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Change Password"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
