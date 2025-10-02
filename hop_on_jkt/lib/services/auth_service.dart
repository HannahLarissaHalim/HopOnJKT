import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

// jembatan antara aplikasi dengan firebase auth + firestore
// logika sign up, login, logout 

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;         // instance firebase auth
  final FirebaseFirestore _db = FirebaseFirestore.instance; // instance firestore

  // SIGN UP 
  // bikin akun baru di firebase auth dan simpan data user di firestore
  // fungsi async, return Future<UserModel?> kalau sukses, ? = boleh null, balikin null kalau gagal
  Future<UserModel?> signUp(String email, String password, String pin) async {
    try {
      // bikin akun firebase pakai email & password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ambil object user dari result, ! = bkn null
      User user = result.user!; 

      // bikin data user lokal pakai UserModel 
      UserModel newUser = UserModel(
        uid: user.uid,
        email: email,
        points: 999,    // default saldo poin
        pin: pin,       // simpan pin dari form signup
      );

      // simpan ke firestore di collection users dengan documentId setiap user = uid pny firebase
      await _db.collection('users').doc(user.uid).set(newUser.toMap());

      return newUser; // kalau sukses
    } catch (e) {
      print("Sign Up Error: $e"); // utk debugging kalo ada error
      return null;
    }
  }

  // LOGIN 
  // masukin email dan password, abis itu ambil data user dari firestore
  Future<UserModel?> login(String email, String password) async {
    try {
      // login ke firebase pake email & password
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ambil user dari hasil login
      User user = result.user!;

      // ambil data profile user dr firestore berdasarkan UID
      DocumentSnapshot doc =
          await _db.collection('users').doc(user.uid).get();

      // return object UserModel ke pemanggil fungsi
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // LOGOUT 

  // RESET PASSWORD
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Reset Password Error: $e");
      throw Exception("Failed to reset password: $e"); // biar bisa ditangkap provider
    }
  }

}
