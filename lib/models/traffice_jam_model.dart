import 'location_model.dart';

class TrafficJamModel {
  final String streetName;
  final LocationModel startLocation;
  final LocationModel endLocation;

  TrafficJamModel({
    required this.streetName,
    required this.startLocation,
    required this.endLocation,
  });

  Map<String, dynamic> toMap() {
    return {
      'street': streetName,
      'startLocation': startLocation.toMap(),
      'endLocation': endLocation.toMap(),
    };
  }
}