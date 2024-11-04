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
}