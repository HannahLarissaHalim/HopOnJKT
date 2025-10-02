// lib/screens/profile/change_pin_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as my_auth;

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isLoading = false;
  bool _verified = false;

  @override
  void dispose() {
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _verifyCurrentPin() async {
    final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
    String currentPin = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Current PIN'),
        content: TextField(
          obscureText: true,
          keyboardType: TextInputType.number,
          onChanged: (value) => currentPin = value,
          decoration: const InputDecoration(hintText: 'Current PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (currentPin.isEmpty) {
      _showError("Please enter your current PIN");
      return;
    }

    if (authProvider.user?.pin != currentPin) {
      _showError("Current PIN is incorrect");
      return;
    }

    setState(() => _verified = true);
  }

  Future<void> _changePin() async {
    final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (newPin.isEmpty || confirmPin.isEmpty) {
      _showError("All fields are required");
      return;
    }

    if (newPin.length != 4) {
      _showError("PIN must be 4 digits");
      return;
    }

    if (newPin != confirmPin) {
      _showError("New PIN and confirmation do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await authProvider.changePin(newPin);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("PIN changed successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError("Failed to change PIN: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Widget _pinField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onToggle,
    required bool obscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: TextInputType.number,
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

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change PIN"),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock, size: 80, color: Colors.purple),
            const SizedBox(height: 20),
            Text(
              _verified ? "Set New PIN" : "Verify Your Current PIN",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (!_verified)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _verifyCurrentPin,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: const Text("Verify Current PIN"),
                ),
              )
            else ...[
              _pinField(
                label: "New PIN",
                controller: _newPinController,
                obscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
              ),
              const SizedBox(height: 12),
              _pinField(
                label: "Confirm New PIN",
                controller: _confirmPinController,
                obscure: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePin,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Change PIN"),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
