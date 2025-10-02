import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage = firebase_storage.FirebaseStorage.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // SIGN UP
  Future<UserModel?> signUp(String email, String password, String pin, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = result.user!;

      UserModel newUser = UserModel(
        uid: user.uid,
        email: email,
        pin: pin,       // simpan pin dari form signup
        points: 999999,
        name: name,
        photoPath: null,
      );

      await _db.collection('users').doc(user.uid).set(newUser.toMap());
      _currentUser = newUser;
      notifyListeners();
      return newUser;
    } catch (e) {
      print("Sign Up Error: $e");
      return null;
    }
  }

  // LOGIN
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = result.user!;
      DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();

      _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      notifyListeners();
      return _currentUser;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // UPDATE PROFILE
  Future<void> updateProfile({
    String? name,
    String? photoPath,
  }) async {
    if (_currentUser == null) {
      throw Exception("User not logged in");
    }

    try {
      Map<String, dynamic> updates = {};

      if (name != null && name.isNotEmpty) {
        updates['name'] = name;
      }

      // Upload foto hanya kalau ada file lokal baru
      if (photoPath != null && photoPath.isNotEmpty && !photoPath.startsWith('http')) {
        print("📤 Uploading photo from: $photoPath");
        String downloadUrl = await _uploadPhoto(photoPath);
        print("✅ Photo uploaded successfully: $downloadUrl");
        updates['photoPath'] = downloadUrl;
      }

      if (updates.isNotEmpty) {
        print("💾 Updating Firestore with: $updates");
        await _db.collection('users').doc(_currentUser!.uid).update(updates);

        // Refresh data user setelah update
        DocumentSnapshot doc = await _db.collection('users').doc(_currentUser!.uid).get();
        _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        print("✅ Profile updated in Firestore");
        notifyListeners();
      }
    } catch (e) {
      print("Update Profile Error: $e");
      rethrow;
    }
  }

  // RESET PASSWORD
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Reset Password Error: $e");
      throw Exception("Failed to reset password: $e");
    }
  }

  // UPLOAD PHOTO HELPER
  Future<String> _uploadPhoto(String localPath) async {
    try {
      File file = File(localPath);
      
      // Validasi file exists
      if (!await file.exists()) {
        throw Exception("File not found at path: $localPath");
      }

      print("📁 File exists, size: ${await file.length()} bytes");

      String fileName = '${_currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Buat reference ke Firebase Storage
      firebase_storage.Reference ref = _storage
          .ref()
          .child('profile_photos')
          .child(fileName);

      print("☁️ Uploading to Firebase Storage: profile_photos/$fileName");

      // Upload file
      firebase_storage.UploadTask uploadTask = ref.putFile(
        file,
        firebase_storage.SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print("📊 Upload progress: ${progress.toStringAsFixed(2)}%");
      });

      // Wait until upload complete
      firebase_storage.TaskSnapshot snapshot = await uploadTask;
      
      print("✅ Upload complete! State: ${snapshot.state}");

      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("🔗 Download URL: $downloadUrl");

      return downloadUrl;
    } on firebase_storage.FirebaseException catch (e) {
      print("❌ Firebase Storage Error:");
      print("   Code: ${e.code}");
      print("   Message: ${e.message}");
      print("   Plugin: ${e.plugin}");
      
      if (e.code == 'object-not-found') {
        throw Exception("Firebase Storage not properly configured. Please check Firebase Console.");
      } else if (e.code == 'unauthorized') {
        throw Exception("Storage permission denied. Please update Firebase Storage Rules.");
      } else if (e.code == 'cancelled') {
        throw Exception("Upload was cancelled.");
      }
      
      rethrow;
    } catch (e) {
      print("❌ Upload photo error: $e");
      rethrow;
    }
  }

  // CHANGE PIN
  Future<void> changePin(String newPin) async {
    if (_currentUser == null) {
      throw Exception("User not logged in");
    }

    try {
      await _db.collection('users').doc(_currentUser!.uid).update({
        'pin': newPin,
      });

      // Refresh user data
      DocumentSnapshot doc = await _db.collection('users').doc(_currentUser!.uid).get();
      _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      notifyListeners();
    } catch (e) {
      print("Change PIN Error: $e");
      rethrow;
    }
  }

  // CHANGE PASSWORD
  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) {
      throw Exception("User not logged in");
    }

    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception("No authenticated user");

      // Re-authenticate user dengan password lama
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Ganti password
      await user.updatePassword(newPassword);

      print("Password changed successfully");
    } catch (e) {
      print("Change Password Error: $e");
      rethrow;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // CHECK AUTH STATE
  Future<void> checkAuthState() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
          notifyListeners();
        }
      } catch (e) {
        print("Check auth state error: $e");
      }
    }
  }
}