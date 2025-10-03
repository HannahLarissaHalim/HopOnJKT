import '../models/route_model.dart';

class JourneyService {
  Future<List<RouteModel>> searchRoutes(
    String from,
    String to,
    DateTime date,
  ) async {
    ////////////////////// list stasiun Jakarta ////////////////////////
    final stations = [
      'Manggarai',
      'Gambir',
      'Jatinegara',
      'Pasar Senen',
      'Tanah Abang',
      'Sudirman',
      'Cikini',
      'Juanda',
      'Duri',
      'Kampung Bandan',
      'Jakarta Kota',
      'Tebet',
      'Pondok Cina',
      'Depok',
      'Universitas Indonesia',
      'Bekasi',
      'Cawang', 
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
      'Lebak Bulus',
    ];

    ////////////// list operator //////////////////////
    final operators = ['KAI Commuter', 'KAI', 'MRT Jakarta', 'LRT Jakarta'];

    //////////// list tipe kereta ////////////////////
    final trainTypes = [
      'Ekonomi',
      'Eksekutif',
      'Premium',
      'Reguler',
      'Express',
    ];

    //////////// Seed random buat hasil tetap sama untuk input yang sama /////////////
    final seed =
        from.hashCode ^ to.hashCode ^ date.day ^ date.month ^ date.year;

    List<RouteModel> routes = [];
    for (int i = 0; i < stations.length; i++) {
      for (int j = 0; j < stations.length; j++) {
        if (i != j) {
          // Untuk beberapa rute, buat 2-3 tiket berbeda
          int tiketCount = 1 + ((i + j + seed) % 3); // 1-3 tiket per rute
          for (int k = 0; k < tiketCount; k++) {
            final localSeed = seed + i * 31 + j * 17 + k * 13;
            final depTime = date.add(
              Duration(minutes: 5 * (i + j + k * 7) + (localSeed % 30)),
            );
            final durasiMenit = 20 + ((i * j + localSeed + k * 5) % 70);
            final arrTime = depTime.add(Duration(minutes: durasiMenit));

            final operator =
                operators[(i * j + localSeed + k) % operators.length];
            final trainType =
                trainTypes[(i + j + localSeed + k) % trainTypes.length];
            final hargaPoin = 100 + ((i + j + k) * 5) + ((localSeed % 100)); 

            routes.add(
              RouteModel(
                departureStation: stations[i],
                arrivalStation: stations[j],
                departureTime: depTime,
                arrivalTime: arrTime,
                duration: arrTime.difference(depTime),
                operator: operator + ' - ' + trainType + ' | ${hargaPoin} Poin',
                routeId:
                    '${stations[i]}-${stations[j]}-${depTime.hour}${depTime.minute}-$k',
                expiryTime: depTime.add(const Duration(minutes: 120)), // expired 2 jam stlh depart
                price: hargaPoin,
                expiryTime: depTime.add(const Duration(minutes: 60)),
              ),
            );
          }
        }
      }
    }

    // filtering data routes berdasarkan input from dan to
    routes = routes
        .where(
          (r) =>
              (from.isEmpty ||
                  r.departureStation.toLowerCase().contains(
                    from.toLowerCase(),
                  )) &&
              (to.isEmpty ||
                  r.arrivalStation.toLowerCase().contains(to.toLowerCase())),
        )
        .toList();


    final now = DateTime.now();

    // filter expired //
    routes = routes.where((r) => r.expiryTime.isAfter(now)).toList();


    // Sorting berdasarkan departure time //
    routes.sort((a, b) => a.departureTime.compareTo(b.departureTime));

    //ambil 50 aja biar lancar
    return routes.take(50).toList();
  }
}