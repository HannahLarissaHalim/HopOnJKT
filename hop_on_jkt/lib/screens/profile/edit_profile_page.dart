import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedAvatar;
  bool _isLoading = false;

  // Daftar avatar dengan emoji/icon
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
      
      // Validasi: pastikan photoPath adalah format avatar ID
      if (user.photoPath != null && user.photoPath!.startsWith('avatar_')) {
        _selectedAvatar = user.photoPath;
      } else {
        // Set default avatar jika format tidak valid
        _selectedAvatar = 'avatar_1';
      }
      
      print("✅ Init - User name: ${user.name}");
      print("✅ Init - User photoPath: ${user.photoPath}");
      print("✅ Init - Selected avatar: $_selectedAvatar");
    } else {
      print("❌ Init - User is null!");
      _selectedAvatar = 'avatar_1'; // Default avatar
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Your Avatar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
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
                            color: isSelected ? Colors.blueAccent : Colors.grey[300]!,
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
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    print("\n=== SAVE PROFILE DEBUG ===");
    print("Name: ${_nameController.text.trim()}");
    print("Selected avatar: ${_selectedAvatar ?? 'null'}");
    print("Current user photoPath: ${authProvider.user?.photoPath}");

    // Validasi input
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
      print("🔄 Calling updateProfile...");
      
      await authProvider.updateProfile(
        name: _nameController.text.trim(),
        photoPath: _selectedAvatar, // Ini akan berupa 'avatar_X'
      );

      print("✅ updateProfile completed");
      print("New user photoPath: ${authProvider.user?.photoPath}");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("❌ Error in _saveProfile: $e");
      print("Error type: ${e.runtimeType}");
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final selectedAvatarOption = _getAvatarOption(_selectedAvatar);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: selectedAvatarOption != null
                              ? Text(
                                  selectedAvatarOption.emoji,
                                  style: const TextStyle(fontSize: 60),
                                )
                              : const Icon(Icons.person, size: 60, color: Colors.grey),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tap to change avatar",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: const OutlineInputBorder(),
                    hintText: user?.email ?? "No email available",
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Save Profile"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

// Model untuk avatar option
class AvatarOption {
  final String id;
  final String emoji;
  final Color color;

  AvatarOption({
    required this.id,
    required this.emoji,
    required this.color,
  });
}