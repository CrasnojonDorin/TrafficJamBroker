import 'dart:convert';
import 'package:trafic_jam/controller/traffic_controller.dart';
import 'package:trafic_jam/models/enum_payload_topic.dart';
import 'package:trafic_jam/models/payload.dart';
import 'package:trafic_jam/models/updated_location.dart';
import 'package:trafic_jam/storage/connection_storage.dart';
import 'package:trafic_jam/storage/payload_storage.dart';

import '../models/connection_info.dart';

// class Worker {
//  // final ReceivePort receivePort;
//
//  // const Worker({required this.receivePort});
//  void isolateFunction(SendPort mainSendPort) {
//    // Crează un ReceivePort pentru a primi mesaje de la threadul principal
//    final receivePort = ReceivePort();
//
//    // Trimite SendPort-ul înapoi la threadul principal
//    mainSendPort.send(receivePort.sendPort);
//
//    // Ascultă mesajele de la threadul principal
//    receivePort.listen((message) {
//      print('Mesaj primit de la threadul principal: $message');
//      // Poți trimite un răspuns înapoi
//      mainSendPort.send('Răspuns din isolate la: $message');
//    });
//  }
//   Future<void> notify(SendPort mainSendPort) async {
//
//     receivePort.listen((message) {
//       if (message is UpdatedLocation) {
//         handleNewLocation(message);
//       }
//     });
//
//   }
//
//   Future<void> handleNewLocation(UpdatedLocation data) async {
//       try {
//         // while (true) {
//           //final data = await PayloadStorage.getNext();
//
//           print(data.toString());
//           //print('Dequeue $data');
//
//
//
//             print('Data From Worker: $data');
//
//             Map<String, dynamic> map = data.location.toMap();
//
//             final index = ConnectionStorage.clients.indexWhere((element) => element.client.id == data.id);
//
//             ConnectionStorage.clients[index].client.setVelocity(time: DateTime.now(), newLocation: data.location);
//
//             map.addAll({
//               "velocity": ConnectionStorage.clients[index].client.velocity.toString(),
//               "name": ConnectionStorage.clients[index].client.name,
//               "id":ConnectionStorage.clients[index].client.id
//             });
//
//             for (var element in ConnectionStorage.clients) {
//               if(element.client.id != data.id){
//                 element.socket.write(jsonEncode(
//                     map
//                 ));}else{
//                 element.socket.write('Speed: ${ConnectionStorage.clients[index].client.velocity?.toStringAsFixed(2)} km/h');
//               }
//             }
//
//
//         //   await Future.delayed(const Duration(milliseconds: 500));
//         // }
//       } catch (e, s) {
//         print('NotifyError $e $s');
//       }
//
//   }
// }

class Worker {
  final TrafficAnalysis controller = TrafficAnalysis();

  Future<void> notify() async {
    try {
      while (true) {
        final data = await PayloadStorage.getNext();

        if (data != null) {
          final index = ConnectionStorage.clients.indexWhere((element) => element.client?.id == data.id);

          final connection = ConnectionStorage.clients[index];

          final client =  connection.client;

          if(data.topic == 'subscribe'){
            connection.socket.write(client?.id);
          }else{
            sendUpdateData(data);
          }
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e, s) {
      print('NotifyError $e $s');
    }
  }

  void sendUpdateData(UpdatedLocation data){
    Map<String, dynamic> map = data.location.toMap();

    final index = ConnectionStorage.clients.indexWhere((element) => element.client?.id == data.id);

    ConnectionStorage.clients[index].client?.setVelocity(time: DateTime.now(), newLocation: data.location);

    handleTrafficController();



    map.addAll({
      "velocity": ConnectionStorage.clients[index].client?.velocity.toString(),
      "name": ConnectionStorage.clients[index].client?.name,
      "id":ConnectionStorage.clients[index].client?.id
    });

    final updatedClientPayload = Payload(topic: PayloadTopic.updateClient, data: ConnectionStorage.clients[index].client?.toMap());

    for (var element in ConnectionStorage.clients) {
      if(element.client?.id != data.id){
        element.socket.write(jsonEncode(updatedClientPayload.toMap()));
      }
      else{

        final speedPayload = Payload(topic: PayloadTopic.getSpeed, data: {'speed': ConnectionStorage.clients[index].client?.velocity?.toStringAsFixed(2)});

        element.socket.write(jsonEncode(speedPayload.toMap()));
      }
    }
  }

  handleTrafficController(){
    controller.checkTrafficJam();
  }
}
