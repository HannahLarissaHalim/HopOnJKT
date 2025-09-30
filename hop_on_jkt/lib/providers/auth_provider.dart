import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// provider buat urus state auth
// ChangeNotifier supaya UI otomatis update kalau ada perubahan data/state (notifyListeners())
class AuthProvider with ChangeNotifier {
  
  // _authService objek dr AuthService, spy provider bisa panggil fungsi dari situ
  final AuthService _authService = AuthService();

  // variabel private yang menyimpan data user yang lagi login.
  UserModel? _user; 

  // getter
  UserModel? get user => _user;         // ambil data user dari luar
  bool get isLoggedIn => _user != null; // cek _user kosong gak


  // SIGN UP
  Future<bool> signUp(String email, String password, String pin) async {
    _user = await _authService.signUp(email, password, pin); // panggil fungsi dari AuthService
    notifyListeners();    // kasih tau UI kalau ada perubahan state
    return _user != null; // return true kalau sukses
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

  // LOGOUT
  
}
