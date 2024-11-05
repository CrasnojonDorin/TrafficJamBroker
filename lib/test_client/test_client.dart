import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:uuid/uuid.dart';

import '../models/location_model.dart';
import '../recources/constans.dart';

void main() async {
  try {
    final Socket socket = await Socket.connect('localhost', Constants.port);
    final oldlat = 47.038451158297995;
    final oldLong = 28.852653477334425;

    String? scene;

    socket.listen((event) {
      final message = String.fromCharCodes(event);

      print('$message');

      try {
        final bool isValidUUID = Uuid.isValidUUID(fromString: message);

        if (isValidUUID) {
          if (scene != null) {
            switch (scene) {
              case 'a':
                testNewData(message, socket);
                break;
              case 'b':
                testNewDataSecondDriver(message, socket);
                break;
              case 'c':
                testNewDataThirdDriverReverse(message, socket);
                break;
            }
          }
          //testNewData(message, socket);
        }
      } catch (e) {
        print(e.toString());
      }
    }, onError: (e) {
      print('Destroy socket $e');
      socket.destroy();
    }, onDone: () {
      print('Destroy socket');
      socket.destroy();
    });

    final (String, String, String) t = await Isolate.run(() {
      String? username;

      String? phone;

      String? scene;

      do {
        print('Enter username:');
        username = stdin.readLineSync();
        print('Enter phone:');
        phone = stdin.readLineSync();
        print('Alege scenariul:\n');
        print(
            'a) Soferul se misca 7 metri pe bulevardul renasterii la diferenta de 3 secunde\n');
        print(
            'b) Soferul se misca inainte la primul sofer cu 7 metri pe bulevardul renasterii la diferenta de 3 secunde\n');
        print(
            'c) Soferul se misca pe bulevardul renasterii in sens opus la a) si b)');
        scene = stdin.readLineSync();
      } while (username == null ||
          username.isEmpty ||
          phone == null ||
          phone.isEmpty ||
          scene == null ||
          scene.isEmpty);

      return (username, phone, scene);
    });

    String username = t.$1;

    String phone = t.$2;

    scene = t.$3;

    final LocationModel location =
        LocationModel(lat: oldlat, long: oldLong, address: 'Street 1');

    final Map<String, dynamic> map = {
      'topic': 'subscribe',
      "name": username,
      "phone": phone,
      "location": location.toMap()
    };

    final data = json.encode(map);

    socket.write(data);
  } catch (e) {
    print('CLient Error: $e');
  }
}

//7m
final newlat = 47.0383999758066;
final newLong = 28.852587763215183;

void testNewData(String id, Socket socket) async {
  await Future.delayed(Duration(seconds: 3));

  final LocationModel newloc = LocationModel(
      lat: newlat, long: newLong, address: 'Bulevardul Renasterii Nationale');

  final Map<String, dynamic> newMap = {
    'topic': 'publish',
    "id": id,
    "location": newloc.toMap()
  };

  final newData = json.encode(newMap);

  print('send test update');

  socket.write(newData);
}

void testNewDataSecondDriver(String id, Socket socket) async {
  await Future.delayed(Duration(seconds: 3));

  final LocationModel newloc = LocationModel(
      lat: newlat + 0.000063,
      long: newLong + 0.000094,
      address: 'Bulevardul Renasterii Nationale');

  final Map<String, dynamic> newMap = {
    'topic': 'publish',
    "id": id,
    "location": newloc.toMap()
  };

  final newData = json.encode(newMap);

  print('send test update');

  socket.write(newData);
}

void testNewDataThirdDriverReverse(String id, Socket socket) async {
  await Future.delayed(Duration(seconds: 3));

  final LocationModel newloc = LocationModel(
      lat: newlat - 0.000063,
      long: newLong - 0.000094,
      address: 'Bulevardul Renasterii Nationale');

  final Map<String, dynamic> newMap = {
    'topic': 'publish',
    "id": id,
    "location": newloc.toMap()
  };

  final newData = json.encode(newMap);

  print('send test update');

  socket.write(newData);
}
