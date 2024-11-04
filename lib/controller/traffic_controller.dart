import 'dart:math';

import 'package:trafic_jam/recources/constans.dart';
import 'package:trafic_jam/storage/connection_storage.dart';

import '../models/client_model.dart';
import '../models/location_model.dart';

class TrafficAnalysis {

  void checkTrafficJam() {
    print('CheckTrafficJam');

    final List<ClientModel> clients = ConnectionStorage.clients.where((e)=>e.client != null).map((e)=>e.client!).toList();
    // Găsim toți clienții cu viteză <= 10 km/h
    List<ClientModel> slowDrivers = clients.where((client) => client.velocity != null && client.velocity! <= Constants.limitSpeed).toList();

    print('Clients: ${clients.map((e)=>e.velocity).toList().toString()} ');

    // Verificăm dacă avem minim doi șoferi pe aceeași stradă
    for (var i = 0; i < slowDrivers.length; i++) {
      for (var j = i + 1; j < slowDrivers.length; j++) {
        if (slowDrivers[i].location?.address == slowDrivers[j].location?.address &&
            _areMovingInSameDirection(slowDrivers[i], slowDrivers[j]) &&
            _areWithinMaxDistance(slowDrivers[i].location!, slowDrivers[j].location!)) {
          print("Atenție: Ambuteiaj detectat! Min 2 șoferi se deplasează cu <= ${Constants.limitSpeed} km/h pe strada ${slowDrivers[i].location?.address}.");
          return; // O alertă este suficientă, ieșim din funcție
        }
      }
    }
  }

  bool _areMovingInSameDirection(ClientModel client1, ClientModel client2) {
    if (client1.velocity != null && client2.velocity != null) {
      double bearing1 = _calculateBearing(client1.location!, client1.location!); // Direcția curentă (se poate adapta în funcție de locația anterioară)
      double bearing2 = _calculateBearing(client2.location!, client2.location!); // Direcția curentă (se poate adapta în funcție de locația anterioară)
      double angleDiff = (bearing1 - bearing2).abs();

      print('AngleDiff $angleDiff');

      return angleDiff < 10; // Un unghi de 10 grade ca toleranță pentru a considera că se îndreaptă în aceeași direcție
    }
    return false;
  }

  bool _areWithinMaxDistance(LocationModel loc1, LocationModel loc2) {
    const double maxDistanceMeters = 10;
    double distance = _calculateDistance(loc1, loc2);
    print('Distanța dintre vehicule: $distance metri');
    return distance <= maxDistanceMeters;
  }

  double _calculateDistance(LocationModel loc1, LocationModel loc2) {
    const double earthRadius = 6371000; // în metri
    double dLat = (loc2.lat! - loc1.lat!) * (pi / 180);
    double dLon = (loc2.long! - loc1.long!) * (pi / 180);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(loc1.lat! * (pi / 180)) * cos(loc2.lat! * (pi / 180)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // rezultatul în metri
  }

  double _calculateBearing(LocationModel from, LocationModel to) {
    const double piOver180 = 0.017453292519943295; // π/180
    double lat1 = from.lat! * piOver180;
    double lat2 = to.lat! * piOver180;
    double deltaLong = (to.long! - from.long!) * piOver180;

    double y = sin(deltaLong) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLong);
    double initialBearing = atan2(y, x);
    // Convertim radianii în grade
    double bearing = (initialBearing * 180 / pi + 360) % 360;
    return bearing;
  }
}
