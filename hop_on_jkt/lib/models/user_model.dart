// class ini representasi data user di aplikasi
// selain data dari firebase auth, ada juga data tambahan yang kita simpan di firestore
// setiap signup, bikin object UserModel, lalu disimpan di firestore
class UserModel {
  final String uid;
  final String email;
  final int points;
  final String pin;
  final String name;          // wajib diisi
  final String? photoPath;    // optional, path foto profil (sekarang berisi avatar ID)

  // constructor
  UserModel({
    required this.uid,
    required this.email,
    required this.points,
    required this.pin,
    required this.name,        // harus diisi
    this.photoPath,           
  });

  // getter untuk cek apakah user punya foto/avatar
  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty;

  // getter untuk cek apakah photoPath adalah avatar ID
  bool get isAvatarId => photoPath != null && photoPath!.startsWith('avatar_');

  // convert object ke Map (misal buat simpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'points': points,
      'pin': pin,
      'name': name,
      'photoPath': photoPath,
    };
  }

  // factory constructor untuk bikin object dari Map (misal dari Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      points: map['points'] is int
          ? map['points']
          : int.tryParse(map['points'].toString()) ?? 100000,
      pin: map['pin']?.toString() ?? '',
      name: map['name']?.toString() ?? 'User', 
      photoPath: map['photoPath']?.toString(), 
    );
  }

  // Helper method untuk copy dengan perubahan
  UserModel copyWith({
    String? uid,
    String? email,
    int? points,
    String? pin,
    String? name,
    String? photoPath,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      points: points ?? this.points,
      pin: pin ?? this.pin,
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, points: $points, photoPath: $photoPath)';
  }
}