import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import untuk menangani SVG
import '../../services/ticket_service.dart';
import '../../widgets/ticket_card.dart';

class OrderHistoryScreen extends StatefulWidget {
  final String userId;
  const OrderHistoryScreen({super.key, required this.userId});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _selectedTab = 'ongoing';
  // Pastikan _ticketsFuture diinisialisasi sebelum digunakan di FutureBuilder
  late Future<List<Map<String, dynamic>>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  // Getter untuk menentukan status yang diminta ke Firestore
  String get firestoreStatus {
    // Jika tab 'history' dipilih, asumsikan status di Firestore adalah 'cancelled' atau 'expired'
    // Menggunakan 'cancelled' sebagai contoh, sesuaikan dengan skema database Anda.
    if (_selectedTab == 'ongoing') return 'active';
    if (_selectedTab == 'history') return 'expired'; // expired
    return 'active';
  }

  // Memuat ulang data tiket berdasarkan tab yang dipilih
  void _loadTickets() {
    // Menginisialisasi future dengan status yang benar
    // Catatan: TicketService().getUserTickets harus tersedia dan mengembalikan Future<List<Map<String, dynamic>>>
    
    final service = TicketService();

    service.markExpiredTickets(widget.userId); // cek expired
    
     setState(() {
    _ticketsFuture = service.getUserTickets(
      widget.userId,
      status: firestoreStatus,
    );
  });
}

  // Fungsi untuk membuat ChoiceChip untuk tab Ongoing dan History
  Widget _buildTabChip(
    String tabName,
    String displayLabel,
    BuildContext context,
  ) {
    const unselectedColor = Color.fromARGB(255, 255, 255, 255);

    return ChoiceChip(
      label: Text(
        displayLabel,
        style: TextStyle(
          color: _selectedTab == tabName
              ? const Color(0xFF3B658D) // teks saat aktif
              : const Color(0xFF248ABA), // teks saat gk aktif
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: _selectedTab == tabName,
      selectedColor: const Color(0xFFA4D1EE), // saat aktif
      backgroundColor: const Color(0xFFE7F2F8), // saat gk aktif
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _selectedTab == tabName
            ? const Color(0xFF3B658D) // border saat aktif
            : const Color(0xFF248ABA), // border saat gk aktif
          width: 1.5,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedTab = tabName;
            _loadTickets(); // Muat data baru saat tab diubah
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Untuk mendapatkan lebar perangkat guna penempatan elemen
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      // =========================================================================
      // APP BAR (Diperbarui agar lebih sesuai dengan desain: Logo + Icon Akun)
      // =========================================================================
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Menghilangkan tombol back default jika ada
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Logo menggunakan SvgPicture
              SvgPicture.asset(
                'assets/images/logo.svg', // Pastikan jalur ini benar
                height: 20,
              ),
            ],
          ),
        ),
      ),
      // -------------------------------------------------------------------------
      // BOTTOM NAVIGATION BAR 
      // -------------------------------------------------------------------------
      // bottomNavigationBar: Container(
      //   decoration: const BoxDecoration(
      //     color: Color(0xFFE3F6FC), // Warna biru muda
      //     boxShadow: [BoxShadow(color: Colors.white, blurRadius: 8)],
      //     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      //   ),
      //   child: Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceAround,
      //       children: const [
      //         Icon(Icons.home, size: 50, color: Colors.black87),
      //         Icon(Icons.confirmation_num, size: 50, color: Colors.black87),
      //         // 2. Ikon Akun (Profil)
      //         CircleAvatar(
      //           radius: 22, // Ukuran lingkaran (sesuaikan agar pas)
      //           backgroundColor: Color.fromARGB(
      //             255,
      //             210,
      //             208,
      //             208,
      //           ), // Warna background abu-abu terang
      //           child: Icon(
      //             Icons
      //                 .person, // Ikon orang (person) terlihat lebih baik dari account_circle
      //             color: Color.fromARGB(
      //               255,
      //               139,
      //               138,
      //               138,
      //             ), // Warna ikon abu-abu gelap
      //             size: 36, // Ukuran ikon di dalam lingkaran
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      // -------------------------------------------------------------------------
      // BODY (Judul, Tab, dan List Tiket)
      // -------------------------------------------------------------------------
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Judul "MY ORDERS" (Ditaruh di body agar sesuai desain)
          const Padding(
            padding: EdgeInsets.only(left: 25.0),
            child: Text(
              'MY ORDERS',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color.fromRGBO(18, 68, 109, 1),
                fontSize: 40,
              ),
            ),
          ),

          // 2. Tab Ongoing & History Selector
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildTabChip('ongoing', 'ongoing', context),
                const SizedBox(width: 10),
                _buildTabChip('history', 'history', context),
              ],
            ),
          ),

          // 3. List Tiket menggunakan FutureBuilder
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _ticketsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final tickets = snapshot.data ?? [];
                if (tickets.isEmpty) {
                  return const Center(child: Text('No tickets found.'));
                }

                // Menggunakan TicketCard untuk menampilkan setiap tiket
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TicketCard(
                        ticket: ticket,
                      ), // Pastikan TicketCard widget ada
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
