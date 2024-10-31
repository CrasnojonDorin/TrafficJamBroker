import 'dart:io';

import 'package:traffic_jam_broker/models/client_model.dart';

class PublisherController {
  final List<ClientModel> clients;

  PublisherController({
    required this.clients
  })

  void publish(ClientModel publisher) {
    for(var subscriber in clients){
      if(subscriber.name != publisher.name){
        handlePublish(subscriber);
      }
    }
  }

  void handlePublish(ClientModel client){
    try{
    Socket.connect(client.socket.remoteAddress, client.socket.remotePort).then((a)=>a.);}catch(e){

    }
  }
}