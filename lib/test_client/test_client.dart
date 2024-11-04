import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:uuid/uuid.dart';

import '../models/location_model.dart';
import '../recources/constans.dart';

void main() async{
  try {
    final Socket socket = await Socket.connect('localhost', Constants.port);

   final oldlat = 47.03497148881504;
   final oldLong = 28.847812288152927;
    final newlat = 47.03479782240975;
    final newLong = 28.847501151911985;

    socket.listen((event) {
      final message = String.fromCharCodes(event);

      print('$message');

      try{
        if(Uuid.isValidUUID(fromString: message)){
          testNewData(message, socket);
        }
      }catch(e){
        print('');
      }
    }, onError: (e) {
      print('Destroy socket $e');
      socket.destroy();
    }, onDone: () {
      print('Destroy socket');
      socket.destroy();
    });



   final (String, String) t = await Isolate.run(() {
     String? username;

     String? phone;

     do {
       print('Enter username:');
       username = stdin.readLineSync();
       print('Enter phone:');
       phone = stdin.readLineSync();
     } while (username == null || username.isEmpty || phone == null ||
         phone.isEmpty);

     return (username, phone);
   }
    );

   String username = t.$1;

   String phone = t.$2;

   final LocationModel location = LocationModel(lat: oldlat,long: oldLong, address: 'Street 1');

    final Map<String, dynamic> map = {
      'topic':'subscribe',
      "name": username,
      "phone": phone,
      "location": location.toMap()
    };

    final data = json.encode(map);

    socket.write(data);

  }catch(e){
    print('CLient Error: $e');
  }
}

void testNewData(String id, Socket socket) async{
  final newlat = 47.03479782240975;
  final newLong = 28.847501151911985;

  await Future.delayed(Duration(seconds: 3));

  final LocationModel newloc = LocationModel(lat: newlat,long: newLong, address: 'Street 1');

  final Map<String, dynamic> newMap = {
    'topic':'publish',
    "id": id,
    "location": newloc.toMap()
  };

  final newData = json.encode(newMap);

  socket.write(newData);
}