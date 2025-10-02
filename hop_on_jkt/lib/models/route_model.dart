class RouteModel {
  final String departureStation;
  final String arrivalStation;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final Duration duration;
  final String operator;
  final String routeId;
  final int price;

  RouteModel({
    required this.departureStation,
    required this.arrivalStation,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.operator,
    required this.routeId,
    required this.price,
  });

  // factory RouteModel.fromJson(Map<String, dynamic> json) {
  //   return RouteModel(
  //     departureStation: json['departureStation'],
  //     arrivalStation: json['arrivalStation'],
  //     departureTime: DateTime.parse(json['departureTime']),
  //     arrivalTime: DateTime.parse(json['arrivalTime']),
  //     duration: Duration(minutes: json['duration']),
  //     operator: json['operator'],
  //     routeId: json['routeId'],
  //   );
  // }
}