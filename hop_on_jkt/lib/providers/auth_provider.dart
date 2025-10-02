import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  // SIGN UP
  Future<bool> signUp(String email, String password, String pin, String name) async {
    _user = await _authService.signUp(email, password, pin, name);
    notifyListeners();
    return _user != null;
  }

  // LOGIN
  Future<bool> login(String email, String password) async {
    _user = await _authService.login(email, password);
    notifyListeners();
    return _user != null;
  }

  // RESET PASSWORD
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  // UPDATE PROFILE
  Future<void> updateProfile({
    String? name,
    String? email,
    String? photoPath,
  }) async {
    if (_user == null) return;
    await _authService.updateProfile(
      name: name,
      photoPath: photoPath,
    );

    // Update user lokal setelah profile berubah
    _user = _authService.currentUser;
    notifyListeners();
  }

  // CHECK AUTH STATE - Method baru ini yang penting!
  Future<void> checkAuthState() async {
    await _authService.checkAuthState();
    _user = _authService.currentUser;
    notifyListeners();
  }

  // LOGOUT
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}