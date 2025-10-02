import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
        points: 999,    // default saldo poin
        pin: pin,       // simpan pin dari form signup
        points: 999999,
        pin: pin,
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
    if (_currentUser == null) return;

    try {
      Map<String, dynamic> updates = {};

      if (name != null && name.isNotEmpty) {
        updates['name'] = name;
      }

      // upload foto hanya kalau ada file baru
      if (photoPath != null && photoPath.isNotEmpty && !photoPath.startsWith('http')) {
        String downloadUrl = await _uploadPhoto(photoPath);
        updates['photoPath'] = downloadUrl;
      }

      if (updates.isNotEmpty) {
        await _db.collection('users').doc(_currentUser!.uid).update(updates);

        // refresh data user setelah update
        DocumentSnapshot doc = await _db.collection('users').doc(_currentUser!.uid).get();
        _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
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
      String fileName = '${_currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      Reference ref = _storage.ref().child('profile_photos').child(fileName);
      UploadTask uploadTask = ref.putFile(file);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Upload photo error: $e");
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
