import 'package:cloud_firestore/cloud_firestore.dart';

class TicketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ambil tiket user berdasarkan userId dan status
  Future<List<Map<String, dynamic>>> getUserTickets(
    String userId, {
    String? status,
  }) async {
    Query query = _firestore
        .collection('tickets')
        .where('userId', isEqualTo: userId);
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // Cancel tiket (update status di Firestore)
  Future<void> cancelTicket(String ticketId) async {
    await _firestore.collection('tickets').doc(ticketId).update({
      'status': 'cancel',
    });
  }

  // Tambah tiket baru
  Future<void> addTicket(Map<String, dynamic> ticketData) async {
    await _firestore.collection('tickets').add(ticketData);
  }

  // buy ticket, kurangi poin, simpan tiket
  Future<void> buyTicket({
    required String userId,                   // id dokumen user di collection "users"
    required int price,                       // harga tiket dalam bentuk poin
    required Map<String, dynamic> ticketData, // data tiket yang akan disimpan
  }) async {
    // referensi ke dokumen user untuk update poin
    final userRef = _firestore.collection('users').doc(userId);

    // transaksi
    await _firestore.runTransaction((transaction) async {

      // ambil snapshot user 
      final snapshot = await transaction.get(userRef);

      // kalau user gak ada
      if (!snapshot.exists) {
        throw Exception("User not found");
      }
      
      // ambil poin saat ini
      final currentPoints = snapshot['points'] ?? 0;

      // cek poin cukup gak
      if (currentPoints < price) {
        throw Exception("Not enough points");
      }

      // update poin user
      transaction.update(userRef, {
        'points': currentPoints - price, // poin baru = poin lama - harga
      });

      // buat referensi dokumen tiket baru di collection "tickets"
      final newTicketRef = _firestore.collection('tickets').doc();

      // simpan data tiket ke firestore
      transaction.set(newTicketRef, {
        ...ticketData,                             
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'expiryTime': DateTime.now().add(Duration(minutes: 120)),
      });
    });
  }

// helper function untuk menandai expired tickets
Future<void> markExpiredTickets(String userId) async {
  final now = DateTime.now();

  final snapshot = await _firestore
      .collection('tickets')
      .where('userId', isEqualTo: userId)
      .where('status', isEqualTo: 'active')
      .get();

  for (final doc in snapshot.docs) {
    final data = doc.data();
    final expiry = data['expiryTime'];

    DateTime expiryTime;
    if (expiry is Timestamp) {
      expiryTime = expiry.toDate();
    } else if (expiry is String) {
      expiryTime = DateTime.tryParse(expiry) ?? now;
    } else {
      continue;
    }

    if (expiryTime.isBefore(now)) {
      await _firestore.collection('tickets').doc(doc.id).update({
        'status': 'expired', // ✅ update status
      });
    }
  }
}

}
