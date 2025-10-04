import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

const Color primaryColor = Color(0xFF1E4D6E);
const Color secondColor = Color.fromARGB(255, 123, 188, 241);
const Color backgroundColor = Color(0xFFF5F9FD);
const Color chipColor = Color(0xFFE0F7FA);

class TopUpPointsPage extends StatefulWidget {
  const TopUpPointsPage({super.key});

  @override
  State<TopUpPointsPage> createState() => _TopUpPointsPageState();
}

class _TopUpPointsPageState extends State<TopUpPointsPage> {
  int? selectedPackage;
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePin = true;

  final Map<int, int> packages = {
    10000: 100,
    25000: 250,
    50000: 500,
    75000: 750,
    100000: 1000,
  };

  void _submitTopUp(AuthProvider authProvider) async {
    if (selectedPackage == null) {
      _showSnackBar("Pilih paket top-up terlebih dahulu", isError: true);
      return;
    }

    String enteredPin = _pinController.text.trim();
    if (enteredPin.isEmpty) {
      _showSnackBar("Masukkan PIN untuk konfirmasi", isError: true);
      return;
    }

    if (enteredPin.length != 6) {
      _showSnackBar("PIN harus 6 digit", isError: true);
      return;
    }

    if (authProvider.user?.pin != enteredPin) {
      _showSnackBar("PIN salah", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      int pointsToAdd = packages[selectedPackage!]!;
      await authProvider.updatePoints(pointsToAdd);

      _showSnackBar("Top-up berhasil! +$pointsToAdd points", isError: false);

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Terjadi kesalahan: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Top Up Points",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: secondColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card dengan Info User
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: secondColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Saldo Points Saat Ini",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${authProvider.user?.points ?? 0} Points",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pilih Paket Top-Up",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Package Cards
                  ...packages.entries.map((entry) {
                    int rupiah = entry.key;
                    int points = entry.value;
                    bool isSelected = selectedPackage == rupiah;
                    
                    return GestureDetector(
                      onTap: () => setState(() => selectedPackage = rupiah),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? secondColor.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? secondColor : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected 
                                  ? secondColor.withOpacity(0.3) 
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: isSelected ? 10 : 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? secondColor : chipColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.monetization_on_rounded,
                                  color: isSelected ? Colors.white : secondColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Rp ${_formatNumber(rupiah)}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? primaryColor : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Dapatkan $points Points",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: secondColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 24),

                  // PIN Input
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              color: primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Konfirmasi dengan PIN",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _pinController,
                          obscureText: _obscurePin,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 8,
                          ),
                          decoration: InputDecoration(
                            hintText: "• • • • • •",
                            filled: true,
                            fillColor: backgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: secondColor, width: 2),
                            ),
                            counterText: "",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePin ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () => setState(() => _obscurePin = !_obscurePin),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _submitTopUp(authProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondColor,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: _isLoading ? 0 : 4,
                        shadowColor: primaryColor.withOpacity(0.4),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.payment_rounded, color: Colors.white),
                                SizedBox(width: 12),
                                Text(
                                  "Top Up Sekarang",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}