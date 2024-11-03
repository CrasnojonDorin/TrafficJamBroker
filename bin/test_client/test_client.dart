import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import '../models/client_model.dart';
import '../models/location_model.dart';
import '../recources/constans.dart';

void main() async{
  try {
    final Socket socket = await Socket.connect('localhost', Constants.port);

    socket.listen((event) {
      final message = String.fromCharCodes(event);

      print('ID: $message');
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

   final LocationModel location = LocationModel(lat: 20,long: 20, address: 'Street 1');

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