import 'dart:convert';
import 'dart:io';
import 'package:trafic_jam/models/enum_payload_topic.dart';
import 'package:trafic_jam/models/payload.dart';
import 'package:trafic_jam/storage/connection_storage.dart';
import 'package:trafic_jam/storage/payload_storage.dart';
import '../models/client_model.dart';
import '../models/connection_info.dart';
import '../models/updated_location.dart';
import '../recources/constans.dart';
import 'package:synchronized/synchronized.dart';

class ServerConfiguration {
  static final Lock lock = Lock();

  void run() async {
    try {
      final ip = InternetAddress.anyIPv4;
      final server = await ServerSocket.bind(ip, Constants.port);
      print('Server is runnig on: ${ip.address}:8080');

      server.listen((e) {
        handleConnection(e, server);
      });
    } catch (e) {
      print('SOMETHING WENT WRONG');
    }
  }

  void handleConnection(Socket client, ServerSocket server) {
    print(
        'Client ${client.remoteAddress.host}:${client.remotePort} was connected');

    final newConnection =ConnectionInfo(socket: client);

    ConnectionStorage.clients.add(newConnection);

    sendClientsToNewConnection(newConnection);

    client.listen((data1) {
      final message = String.fromCharCodes(data1);

      final data = json.decode(message);

      if (data is Map<String, dynamic>) {
        if (data.containsKey('topic')) {
          if (data['topic'] == 'subscribe') {
            subscribe(client: newConnection, data: data);
          } else if (data['topic'] == 'publish') {
            final location = UpdatedLocation.fromMap(data);
            publish(location);
          }
        }
      }
    }, onDone: () {
      print('Server: Client left');
      removeAndNotifyClients(client);
    }, onError: (e) {
      removeAndNotifyClients(client);
      print('WARNING Server: Client left');
    });
  }

  void sendClientsToNewConnection(ConnectionInfo newConnection) {
    List<ConnectionInfo> targetClients = [];

    for (var element in ConnectionStorage.clients) {
      if (element.client?.id != newConnection.client?.id) {
        targetClients.add(element);
      }
    }

    final clients =
   targetClients.map((e) => e.client?.toMap()).toList();

    final clientsPayload = Payload(topic: PayloadTopic.getClients, data: clients);

    newConnection.socket.write(clientsPayload.toMap());
  }

  void removeAndNotifyClients(Socket client) {
    try {
      //print(client.remotePort.toString());

      final index = ConnectionStorage.clients.indexWhere(
          (element) => element.socket.remotePort == client.remotePort);

      if (index != -1) {
        final id = ConnectionStorage.clients[index].client?.id;

        ConnectionStorage.clients.removeAt(index);

        for (var element in ConnectionStorage.clients) {
          element.socket.write('Remove $id');
        }
      }
    } catch (e) {
      print('NotifyLeftedClient Error $e');
    }

    client.close();
  }

  void subscribe({required ConnectionInfo client, required Map<String, dynamic> data}) {
    try {
      final clientFromMap = ClientModel.fromMap(data);

      final bool check = checkIfExistUser(clientFromMap);

      if (check) {
        return;
      }

      print('${clientFromMap.name} join the party');

      client.client = clientFromMap;

      if (clientFromMap.location != null) {
        final entity = UpdatedLocation(topic: 'subscribe',
            location: clientFromMap.location!, id: clientFromMap.id);

        PayloadStorage.add(entity);
      }
    } catch (e, s) {
      print('SubscribeError $e $s');
    }
  }

  bool checkIfExistUser(ClientModel newModel) {
    final i =
        ConnectionStorage.clients.indexWhere((e) => newModel.id == e.client?.id);

    print('Client Index: $i');

    return i != -1;
  }

  void publish(UpdatedLocation location) {
    print(location.location.address);
    PayloadStorage.add(location);
  }
}
