import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:traffic_jam_broker/models/client_model.dart';

class ServerConfiguration {

  void run() async {
    final ip = InternetAddress.anyIPv4;
    final server = await ServerSocket.bind(ip, 8080);
    print('Server is runnig on: ${ip.address}:8080');

    server.listen((e) {
      handleConnection(e, server);
    });
  }

  List<ClientModel> clients = [];

  void handleConnection(Socket client, ServerSocket server) {
    client.listen((data) {
      final message = String.fromCharCodes(data);

      final deserialization = json.decode(message);

      final client = ClientModel.fromMap(deserialization);

      log('${client.getName} join to server');

      clients.add(client);

      clients.forEach((e){
        if(client.getName != e.getName){
          server.
        }
      });
    }, onError: (e) {
      log('Server: Client left', name: 'WARNING');
      client.close;
    });
  }
}
