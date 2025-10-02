import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProfileImage(String userId, File file) async {
    try {
      // Simpan di folder profile_photos/<userId>.jpg
      final ref = _storage.ref().child('profile_photos').child('$userId.jpg');

      await ref.putFile(file);

      // Ambil link download
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Upload photo error: $e");
      return null;
    }
  }
}
