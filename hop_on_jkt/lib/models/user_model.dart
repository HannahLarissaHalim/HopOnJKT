// class ini representasi data user di aplikasi
// selain data dr firebase auth, ada jg data tambahan yang kita simpan di firestore
// setiap signup, bikin object UserModel, lalu disimpan di firestore

class UserModel {
  final String uid;
  final String email;
  final int points;
  final String pin;

  // constructor
  UserModel({
    required this.uid,
    required this.email,
    required this.points,
    required this.pin,
  });

  // convert object jd map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'points': points,
      'pin': pin,
    };
  }

  // factory constructor buat bikin object dari data firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      points: map['points'] is int
          ? map['points']
          : int.tryParse(map['points'].toString()) ?? 0,
      pin: map['pin']?.toString() ?? '',
    );
  }
}
