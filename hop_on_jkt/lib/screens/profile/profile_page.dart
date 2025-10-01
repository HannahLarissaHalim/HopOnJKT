import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart'; 

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();  
    final user = auth.user;  

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "HopOnJKT",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: user?.hasPhoto == true && user!.photoPath != null
                              ? (user.photoPath!.startsWith('http')
                                  ? NetworkImage(user.photoPath!)
                                  : FileImage(File(user.photoPath!)) as ImageProvider)
                              : null,
                          child: user?.hasPhoto != true
                              ? Icon(Icons.person, size: 50, color: Colors.grey[700])
                              : null,
                        ),
                        const SizedBox(height: 12),
                        
                        Text(
                          user?.name ?? 'User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),

                        _FeatureButton(
                          text: "Edit Profile",
                          icon: Icons.edit,
                          onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                        ),
                        _FeatureButton(
                          text: "FAQ",
                          icon: Icons.help_outline,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('FAQ coming soon')),
                            );
                          },
                        ),
                        _FeatureButton(
                          text: "Rate this app",
                          icon: Icons.star_outline,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Rate feature coming soon')),
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () {
                            _showLogoutDialog(context, auth);
                          },
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            "Log Out",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Container(
              color: const Color(0xFFDFF4FF),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.home, size: 28),
                  Icon(Icons.list_alt, size: 28),
                  Icon(Icons.person, size: 28, color: Colors.black54),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pop(c);
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.blue[900],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}