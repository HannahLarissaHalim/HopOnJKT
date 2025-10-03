import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class TopUpPointsPage extends StatefulWidget {
  const TopUpPointsPage({super.key});

  @override
  State<TopUpPointsPage> createState() => _TopUpPointsPageState();
}

class _TopUpPointsPageState extends State<TopUpPointsPage> {
  int? selectedPackage; // nominal rupiah
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePin = true;

  // Paket top-up nominal rupiah -> points
  final Map<int, int> packages = {
    10000: 100,
    25000: 250,
    50000: 500,
    75000: 750,
    100000: 1000,
  };

  void _submitTopUp(AuthProvider authProvider) async {
    if (selectedPackage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih paket top-up terlebih dahulu")),
      );
      return;
    }

    String enteredPin = _pinController.text.trim();
    if (enteredPin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan PIN untuk konfirmasi")),
      );
      return;
    }

    if (enteredPin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN harus 4 digit")),
      );
      return;
    }

    // Cek PIN
    if (authProvider.user?.pin != enteredPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN salah")),
      );
      return;
    }

    // Tambahkan points
    setState(() => _isLoading = true);
    try {
      int pointsToAdd = packages[selectedPackage!]!;
      await authProvider.updatePoints(pointsToAdd);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Top-up berhasil! +$pointsToAdd points")),
      );

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Top Up Points"),
        backgroundColor: const Color(0xFF1A3C6E),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pilih Paket Top-Up",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // List Paket
            Column(
              children: packages.entries.map((entry) {
                int rupiah = entry.key;
                int points = entry.value;
                return RadioListTile<int>(
                  title: Text("Rp ${rupiah.toString()} → $points points"),
                  value: rupiah,
                  groupValue: selectedPackage,
                  onChanged: (val) {
                    setState(() => selectedPackage = val);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              obscureText: _obscurePin,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: "Masukkan PIN",
                border: const OutlineInputBorder(),
                counterText: "",
                suffixIcon: IconButton(
                  icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _submitTopUp(authProvider),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF1A3C6E),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Top Up Sekarang",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
