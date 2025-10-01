import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';  // ← GANTI IMPORT

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  String? _localImagePath;
  String? _networkImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;  // ← GANTI
    if (user != null) {
      _nameC.text = user.name;
      _emailC.text = user.email;
      if (user.photoPath != null) {
        if (user.photoPath!.startsWith('http')) {
          _networkImageUrl = user.photoPath;
        } else {
          _localImagePath = user.photoPath;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource src) async {
    if (_isPicking) return;
    _isPicking = true;
    try {
      final picked = await _picker.pickImage(source: src, maxWidth: 800, maxHeight: 800);
      if (picked != null) {
        setState(() {
          _localImagePath = picked.path;
          _networkImageUrl = null;
        });
      }
    } catch (e) {
      debugPrint('Pick image error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    } finally {
      _isPicking = false;
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    
    try {
      final auth = context.read<AuthProvider>();  // ← GANTI
      await auth.updateProfile(
        name: _nameC.text.trim().isEmpty ? null : _nameC.text.trim(),
        email: _emailC.text.trim().isEmpty ? null : _emailC.text.trim(),
        photoPath: _localImagePath,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showPickOptions,
              child: Stack(
                children: [
                  _getAvatarWidget(),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _showPickOptions,
              child: const Text('Change photo', style: TextStyle(color: Colors.blueAccent)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameC,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailC,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getAvatarWidget() {
    if (_localImagePath != null) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(File(_localImagePath!)),
      );
    } else if (_networkImageUrl != null) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: NetworkImage(_networkImageUrl!),
      );
    } else {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.person, size: 60, color: Colors.grey[700]),
      );
    }
  }

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      builder: (c) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(c);
                _pick(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(c);
                _pick(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}