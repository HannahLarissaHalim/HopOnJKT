import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ChangeNotifier supaya bisa kasih tahu UI kalau ada data/state berubah
class AuthProvider extends ChangeNotifier {
  // instance FirebaseAuth & Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance; 
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 

  // state yang disimpan, ? supaya boleh null
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  // getter, arrow function untuk return
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  bool get isAuthenticated => _user != null;

  // constructor
  // listener utk deteksi kalau user login/logout
  AuthProvider() {
    // listen perubahan user
    _auth.authStateChanges().listen((User? user) {
      // simpan user ke state
      _user = user;
      
      if (user != null) {
        _loadUserData();  // kalau login, load data firestore
      } else {
        _userData = null; // kalau logout, data user kosong
      }
      notifyListeners();  // update UI/refresh
    });
  }

  // fungsi untuk load data user dari firestore berdasarkan UID
  // pakai future krn butuh waktu (ambil data dari firestore), void krn cuma update _userData
  // fungsi privat pakai _
  Future<void> _loadUserData() async {
    // cek user ada gak
    if (_user != null) {
      // ambil dokumen dari collection users berdasarkan UID
      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(_user!.uid)
            .get();
        // simpan ke _userData
        if (doc.exists) {
          _userData = doc.data() as Map<String, dynamic>;
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  // login
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;    
    _errorMessage = null;
    notifyListeners();

    // coba login 
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // kalau berhasil simpan user + load data dari firestore
      _user = userCredential.user;
      await _loadUserData();
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {  // kalau gagal simpan error message
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // sign up
  Future<bool> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // coba buat akun
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // simpan user baru
      _user = userCredential.user; 

      // simpan data ke firestore
      await _firestore.collection('users').doc(_user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'memberSince': DateTime.now().toIso8601String(),
      });

      // load data user
      await _loadUserData();
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) { // kalau error
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // logout
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _userData = null;
    notifyListeners();
  }

  // reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // kirim email reset password 
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code); // kalau gagal simpan error message.
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // error handler
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'network-request-failed':
        return 'Network error.';
      default:
        return 'An error occurred.';
    }
  }
}
