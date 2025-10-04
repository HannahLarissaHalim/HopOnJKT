import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

const Color primaryColor = Color(0xFF1E4D6E);
const Color secondColor = Color.fromARGB(255, 123, 188, 241);
const Color backgroundColor = Color(0xFFF5F9FD);
const Color chipColor = Color(0xFFE0F7FA);
const Color headerBgColor = Color(0xFFD7E7F0);

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
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
                    color: avatar.color.withOpacity(0.2),
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.grey[300]!,
                      width: isSelected ? 3 : 1,
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
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name cannot be empty!")),
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
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always, // label tetap di atas
          hintText: hint,
          labelStyle: TextStyle(color: primaryColor.withOpacity(0.7), fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: chipColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: secondColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // → kotak lebih kecil
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedAvatarOption = _getAvatarOption(_selectedAvatar);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [headerBgColor, chipColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
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
                            color: selectedAvatarOption?.color.withOpacity(0.2) ?? Colors.grey[200],
                            border: Border.all(color: Colors.grey[300]!, width: 2),
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
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Tap avatar to change",
                    style: TextStyle(fontSize: 14, color: primaryColor.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 16),
                  _textField(label: "Username", controller: _nameController),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: primaryColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        "Save Profile",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
