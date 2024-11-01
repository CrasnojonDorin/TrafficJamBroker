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

      client.socket.listen((a){

      });

      log('${client.name} join to server');

      clients.add(client);

      clients.forEach((e){
        if(client.name != e.name){
          e.socket?.write('alio');
        }
      });
    }, onError: (e) {
      log('Server: Client left', name: 'WARNING');
      client.close;
    });
  }
}
