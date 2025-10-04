import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

const Color primaryColor = Color(0xFF1E4D6E);
const Color secondColor = Color.fromARGB(255, 123, 188, 241);
const Color backgroundColor = Color(0xFFF5F9FD);
const Color chipColor = Color(0xFFE0F7FA);

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedAvatar;
  bool _isLoading = false;

  final List<AvatarOption> _avatarList = [
    AvatarOption(id: 'avatar_1', emoji: '😀', color: Colors.blue),
    AvatarOption(id: 'avatar_2', emoji: '😎', color: Colors.orange),
    AvatarOption(id: 'avatar_3', emoji: '🥳', color: Colors.purple),
    AvatarOption(id: 'avatar_4', emoji: '😇', color: Colors.green),
    AvatarOption(id: 'avatar_5', emoji: '🤩', color: Colors.pink),
    AvatarOption(id: 'avatar_6', emoji: '🤗', color: Colors.teal),
    AvatarOption(id: 'avatar_7', emoji: '😊', color: Colors.amber),
    AvatarOption(id: 'avatar_8', emoji: '🙂', color: Colors.indigo),
    AvatarOption(id: 'avatar_9', emoji: '😃', color: Colors.red),
    AvatarOption(id: 'avatar_10', emoji: '🤔', color: Colors.cyan),
    AvatarOption(id: 'avatar_11', emoji: '😺', color: Colors.deepOrange),
    AvatarOption(id: 'avatar_12', emoji: '🐶', color: Colors.brown),
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      if (user.photoPath != null && user.photoPath!.startsWith('avatar_')) {
        _selectedAvatar = user.photoPath;
      } else {
        _selectedAvatar = 'avatar_1';
      }
    } else {
      _selectedAvatar = 'avatar_1';
    }
  }

  AvatarOption? _getAvatarOption(String? avatarId) {
    if (avatarId == null) return null;
    try {
      return _avatarList.firstWhere((av) => av.id == avatarId);
    } catch (e) {
      return null;
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 450,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Choose Your Avatar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _avatarList.length,
                    itemBuilder: (context, index) {
                      final avatar = _avatarList[index];
                      final isSelected = _selectedAvatar == avatar.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAvatar = avatar.id;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: avatar.color.withOpacity(0.15),
                            border: Border.all(
                              color: isSelected ? secondColor : Colors.grey[300]!,
                              width: isSelected ? 3 : 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              avatar.emoji,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Name cannot be empty!"),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await authProvider.updateProfile(
        name: _nameController.text.trim(),
        photoPath: _selectedAvatar,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Profile updated successfully!"),
            backgroundColor: secondColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update profile: $e"),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedAvatarOption = _getAvatarOption(_selectedAvatar);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: secondColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: secondColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showAvatarPicker,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedAvatarOption?.color.withOpacity(0.2) ?? chipColor,
                            border: Border.all(color: secondColor, width: 3),
                          ),
                          child: Center(
                            child: selectedAvatarOption != null
                                ? Text(selectedAvatarOption.emoji, style: const TextStyle(fontSize: 60))
                                : const Icon(Icons.person, size: 60, color: Colors.grey),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: secondColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Tap to change avatar",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Username Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    "Username",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: secondColor.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "Enter your name",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.person_outline, color: secondColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: secondColor, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: secondColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "Save Changes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
    _nameController.dispose();
    super.dispose();
  }
}

class AvatarOption {
  final String id;
  final String emoji;
  final Color color;
  AvatarOption({required this.id, required this.emoji, required this.color});
}