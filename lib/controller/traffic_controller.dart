import 'dart:math';

import '../models/client_model.dart';
import '../models/location_model.dart';

class TrafficAnalysis {
  List<ClientModel> clients;

  TrafficAnalysis(this.clients);

  void checkTrafficJam() {
    // Găsim toți clienții cu viteză <= 10 km/h
    List<ClientModel> slowDrivers = clients.where((client) => client.velocity != null && client.velocity! <= 10).toList();

    // Verificăm dacă avem minim doi șoferi pe aceeași stradă
    for (var i = 0; i < slowDrivers.length; i++) {
      for (var j = i + 1; j < slowDrivers.length; j++) {
        if (slowDrivers[i].location?.address == slowDrivers[j].location?.address && _areMovingInSameDirection(slowDrivers[i], slowDrivers[j])) {
          print("Atenție: Ambuteiaj detectat! Min 2 șoferi se deplasează cu <= 10 km/h pe aceeași direcție.");
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
      return angleDiff < 10; // Un unghi de 10 grade ca toleranță pentru a considera că se îndreaptă în aceeași direcție
    }
    return false;
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
