import 'dart:convert';
import 'dart:io';
import '../controller/threade_safe_queue.dart';
import '../models/client_model.dart';
import '../models/connection_info.dart';
import '../models/updated_location.dart';
import '../recources/constans.dart';

class ServerConfiguration {
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

  List<ConnectionInfo> clients = [];

  final queue = ThreadSafeQueue<UpdatedLocation>();

  void handleConnection(Socket client, ServerSocket server) {
    print('Client ${client.port}:${client.port} was connected');

    client.listen((data1) {
      final message = String.fromCharCodes(data1);

      final data = json.decode(message);

      if (data is Map<String, dynamic>) {
        if (data.containsKey('topic')) {
          if (data['topic'] == 'subscribe') {
            subscribe(client: client, data: data);
          } else if (data['topic'] == 'publish') {
            final location = UpdatedLocation.fromMap(data);
            publish(location);
          }
        }
      }
    }, onDone: () {
      print('Server: Client left');
    }, onError: (e) {
      print('WARNING Server: Client left');
      client.close;
    });
  }

  void subscribe({required Socket client, required Map<String, dynamic> data}) {
    try {
      final clientFromMap = ClientModel.fromMap(data);

      client.write(clientFromMap.id);

      print('${clientFromMap.name} join the party');

      final ConnectionInfo connectionInfo =
          ConnectionInfo(socket: client, id: clientFromMap.id);

      clients.add(connectionInfo);

      if (clientFromMap.location != null) {
        final entity = UpdatedLocation(
            location: clientFromMap.location!, id: clientFromMap.id);

        queue.enqueue(entity);
      }
    } catch (e, s) {
      print('SubscribeError $e $s');
    }
  }

  void publish(UpdatedLocation location) {
    queue.enqueue(location);
  }
}