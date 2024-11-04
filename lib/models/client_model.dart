import 'dart:math';
import 'location_model.dart';
import 'package:uuid/uuid.dart';

class ClientModel {
  final String name;
  final String phone;
  final String id;
  DateTime timeUpdated;
  LocationModel? location;
  double? velocity;

  ClientModel(
      { required this.name, required this.phone, this.location, this.velocity})
      : id = const Uuid().v5(Uuid.NAMESPACE_URL, phone), timeUpdated = DateTime.now();

  void setVelocity({required DateTime time, required LocationModel newLocation}) {
    // Verificăm că diferența de timp este mai mică de 5 secunde
    if (time.difference(timeUpdated).inSeconds < 5 && location != null && location!.long != null && location!.lat != null) {
      // Calculăm distanța în metri dintre cele două locații
      double distance = calculateDistance(
        location!.lat!,
        location!.long!,
        newLocation.lat!,
       newLocation.long!,
      );

      print('Distance $distance');

      // Calculăm timpul în secunde între cele două locații
      double timeInSeconds = time.difference(timeUpdated).inSeconds.toDouble();

      // Calculăm viteza în metri pe secundă
      velocity = (distance / timeInSeconds)*3.6;

      print('$name has $velocity km/h');

      // Actualizăm ultima locație și timpul
      location = newLocation;
      timeUpdated = time;
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000; // raza Pământului în metri
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'id': id,
      'velocity': velocity.toString(),
      'location': location?.toMap(),
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      name: map['name'] as String,
      phone: map['phone'] as String,
      location: LocationModel.fromMap(map['location']),
    );
  }
}
