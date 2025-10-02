import 'package:flutter/material.dart';
import '../../models/route_model.dart';
import '../../services/journey_service.dart';
import '../../widgets/bottom_navbar.dart';
import '../ticket/buy_ticket_screen.dart';


/////////////////// template Warna /////////////// //////////////
const Color primaryColor = Color(0xFF1E4D6E); 
const Color SecondColor = Color.fromARGB(255, 123, 188, 241); 
const Color BackgroundColor = Color(0xFFF5F9FD); 
const Color ChipColor = Color(0xFFE0F7FA);
const Color HeaderBgColor = Color(0xFFD7E7F0);

class RouteScreen extends StatefulWidget {
  final String from;
  final String to;
  final DateTime date;

  const RouteScreen({
    Key? key,
    required this.from,
    required this.to,
    required this.date,
  }) : super(key: key);

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  /////////////////////////// Daftar stasiun jakarta ////////////////////////////
  final List<String> _stations = [
    'Lebak Bulus',
    'Blok A',
    'Manggarai',
    'Jakarta Kota',
    'Gambir',
    'Jatinegara',
    'Pasar Senen',
    'Tanah Abang',
    'Sudirman',
    'Cikini',
    'Juanda',
    'Duri',
    'Kampung Bandan',
    'Tebet',
    'Cawang',
    'Pondok Cina',
    'Depok',
    'Universitas Indonesia',
    'Bekasi',
    'Klender',
    'Buaran',
    'Cakung',
    'Kranji',
    'Cilebut',
    'Bogor',
    'Citayam',
    'Lenteng Agung',
    'Pancasila',
    'Palmerah',
    'Kebayoran',
    'Pondok Ranji',
    'Serpong',
    'Parung Panjang',
    'Maja',
    'Rangkasbitung',
  ].toSet().toList(); 

  late String _selectedFrom;
  late String _selectedTo;
  late Future<List<RouteModel>> _routesFuture;

  @override
  void initState() {
    super.initState();

    ///////////////////// sebelum memilih dropdown, otomatis milih manggarai sama jakarta ///////////////
    const defaultFrom = 'Manggarai';
    const defaultTo = 'Jakarta Kota';

    _selectedFrom = _stations.contains(widget.from) ? widget.from : defaultFrom;
    _selectedTo = _stations.contains(widget.to) ? widget.to : defaultTo;

    if (!_stations.contains(_selectedFrom) && _stations.isNotEmpty) {
      _selectedFrom = _stations.first;
    }
    if (!_stations.contains(_selectedTo) && _stations.length > 1) {
      _selectedTo = _stations[1];
    } else if (!_stations.contains(_selectedTo) && _stations.isNotEmpty) {
      _selectedTo = _stations.first;
    }


    _searchRoutes();
  }

  void _searchRoutes() {
    setState(() {
      _routesFuture = JourneyService().searchRoutes(
        _selectedFrom,
        _selectedTo,
        widget.date,
      );
    });
  }

  void _navigateToPurchase(RouteModel route) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BuyTicketScreen(
        fromStation: route.departureStation,
        toStation: route.arrivalStation,
        price: route.price,
      ),
    ),
  );
}


  /////////////// Komponen Dropdown Stasiun //////////////
  Widget _buildStationDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    String? displayValue = _stations.contains(value) ? value : null;
    if (displayValue == null && _stations.isNotEmpty) {
      displayValue = _stations.first;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), 
      height: 50,
      decoration: BoxDecoration(
        color: SecondColor, 
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: displayValue, 
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          isExpanded: true,
          dropdownColor: Colors.white,

          selectedItemBuilder: (BuildContext context) {
            return _stations.map((String station) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Text(
                    station,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList();
          },
          
          items: _stations.map((station) {
            return DropdownMenuItem(
              value: station,
              child: Text(
                station,
                style: const TextStyle(color: primaryColor), 
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  ////////////// Komponen Chip Stasiun kecil ////////////////
  Widget _buildStationChip(String stationName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ChipColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        stationName,
        style: const TextStyle(
          color: primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRouteCard(RouteModel route) {
    String priceText = 'XXXX Poin';
    
    final parts = route.operator.split('|');
    if (parts.length > 1) {
      priceText = parts.last.trim();
    } else {
        priceText = 'XXXX Poin'; 
    }
    
    final depTime = 
        '${route.departureTime.hour}:${route.departureTime.minute.toString().padLeft(2, '0')}';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      elevation: 4,
      color: Colors.white, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column( 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///////// Chips Stasiun (biar bisa kyk gini, a -> b) ///////////////
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildStationChip(route.departureStation),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.arrow_right_alt, color: Colors.grey, size: 20),
                ),
                _buildStationChip(route.arrivalStation),
              ],
            ),
            
            const SizedBox(height: 12), 
            
            ////// Detail Waktu, Durasi, Harga dan Tombol Buy Ticket //////////////
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /////////////////////// Detail waktu, durasi, harga //////////////////////////
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Depart $depTime',
                      style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('Duration: ${route.duration.inMinutes} min', style:  const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('price: $priceText', 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 7, 125, 15))), 
                  ],
                ),
                
                //////////////////// Tombol Buy Ticket ///////////////////////////////
                ElevatedButton(
                  onPressed: () => _navigateToPurchase(route),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, 
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0,
                  ),
                  child: const Text('Buy Ticket',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: BackgroundColor,
      body: Stack(
        children: [
          //////////////// BACKGROUND BIRU MUDA ///////////////////////////
          Container(
            height: screenHeight * 0.45,
            width: double.infinity,
            color: HeaderBgColor,
          ),

          ////////////////// ILUSTRASI KERETA DI BACKGROUND //////////////////////
          Positioned(
            top: screenHeight * 0.05, 
            width: MediaQuery.of(context).size.width * 1.5, 
            height: screenHeight * 0.4, 
            left: MediaQuery.of(context).size.width * 0.0, 
            child: Image.asset(
              'assets/images/kereta.png', 
              fit: BoxFit.fitWidth, 
              alignment: Alignment.bottomCenter, 
            ),
          ),

          /////////////// KONTEN UTAMA (Teks, Ikon, Card Input) ////////////////
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HopOnJKT',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            // ..style = PaintingStyle.stroke
                            // ..strokeWidth = 1.5 
                            ..color = primaryColor, 
                        ),
                      ),
                      
                      //////////////////////////////////// Ikon Akun ////////////////////////////////////
                      // GestureDetector(
                      //   onTap: () {
                      //     Navigator.pushNamed(context, '/account'); //diarahin ke detail akun user
                      //   },
                      //   child: Container(
                      //     width: 36,
                      //     height: 36,
                      //     decoration: BoxDecoration(
                      //       color: Colors.grey.shade300,
                      //       shape: BoxShape.circle,
                      //     ),
                      //     child: const Icon(Icons.person, color: Colors.grey),
                      //   ),
                      // ),
                    ],
                  ),
                ),

                /////////////////////// Teks "Where do you Want to go //////////////////////// 
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Text(
                    'Where do you \nWant to go?',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: primaryColor,
                    ),
                  ),
                ),

                ////////////////// Card Input buat Rute ///////////////////////////
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 20.0), 
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ///////////////// Input Stasiun Asal dengan Dropdown /////////////////////
                        _buildStationDropdown(
                          label: 'stasiun awal',
                          value: _selectedFrom,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedFrom = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        ////////////////// Input Stasiun Tujuan dengan Dropdown ///////////////////////
                        _buildStationDropdown(
                          label: 'stasiun tujuan',
                          value: _selectedTo,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedTo = value);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        ////////////////////// Tombol Show Ticket ////////////////////////////////
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _searchRoutes,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('Show Ticket',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                ///////////////////// Hasil Pencarian Rute ///////////////////////////////////
                Expanded(
                  child: FutureBuilder<List<RouteModel>>(
                    future: _routesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(color: primaryColor));
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text('Error: ${snapshot.error}',
                                style: const TextStyle(color: primaryColor)));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text('Tidak ada rute yang bisa ditemukan',
                                  style: TextStyle(color: primaryColor)),
                            ));
                      }

                      final routes = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: routes.length,
                        itemBuilder: (context, index) {
                          final route = routes[index];
                          return _buildRouteCard(route);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // //////////////// Navigator ///////////////////////////
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.white,
      //   selectedItemColor: primaryColor, 
      //   unselectedItemColor: Colors.grey,
      //   currentIndex: 0, 
      //   showSelectedLabels: false,
      //   showUnselectedLabels: false,
      //   type: BottomNavigationBarType.fixed, 
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home, size: 30),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.credit_card, size: 30),
      //       label: 'Ticket',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.swap_horiz, size: 30),
      //       label: 'Swap',
      //     ),
      //   ],
      //   onTap: (index) {
      //     ///////////// Implementasi navigasi bottom bar di sini ///////////////////
      //   },
      // ),
    );
  }
}