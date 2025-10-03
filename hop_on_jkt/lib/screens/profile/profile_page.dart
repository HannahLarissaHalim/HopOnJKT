import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import 'edit_profile_page.dart';
import 'top_up_points_page.dart'; 
import 'faq_page.dart';
import 'rate_page.dart';
import 'change_password_screen.dart'; 
import 'change_pin_screen.dart';      

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Widget _buildProfileImage(String? photoPath) {
    // Cek apakah photoPath adalah URL atau path lokal
    if (photoPath != null && photoPath.isNotEmpty) {
      if (photoPath.startsWith('http')) {
        return CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          backgroundImage: NetworkImage(photoPath),
        );
      } else {
        return CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          backgroundImage: FileImage(File(photoPath)),
        );
      }
    }

    // Default avatar jika tidak ada foto
    return const CircleAvatar(
      radius: 60,
      backgroundColor: Colors.white,
      child: Icon(Icons.person, size: 70, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1A3C6E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER PROFILE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: const BoxDecoration(
                color: Color(0xFF1A3C6E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Profile Photo
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _buildProfileImage(user?.photoPath),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? "Guest User",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.email ?? "No email available",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Points Badge
                 GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TopUpPointsPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            "${user?.points ?? 0} Points",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A3C6E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// MENU LIST
            _buildMenuTile(
              context,
              icon: Icons.edit,
              iconColor: const Color(0xFF1A3C6E),
              title: "Edit Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
              },
            ),
            
            const Divider(height: 1),
            
            _buildMenuTile(
              context,
              icon: Icons.lock,
              iconColor: Colors.orange,
              title: "Change Password",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                );
              },
            ),
            
            const Divider(height: 1),
            
            _buildMenuTile(
              context,
              icon: Icons.pin,
              iconColor: Colors.purple,
              title: "Change PIN",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePinScreen()),
                );
              },
            ),
            
            const Divider(height: 1),
            
            _buildMenuTile(
              context,
              icon: Icons.help_outline,
              iconColor: Colors.green,
              title: "FAQ",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FaqPage()),
                );
              },
            ),
            
            const Divider(height: 1),
            
            _buildMenuTile(
              context,
              icon: Icons.star_rate,
              iconColor: Colors.amber,
              title: "Rate This App",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RatePage()),
                );
              },
            ),
            
            const Divider(height: 1),
            
            _buildMenuTile(
              context,
              icon: Icons.logout,
              iconColor: Colors.red,
              title: "Logout",
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true && context.mounted) {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, "/login");
                  }
                }
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
