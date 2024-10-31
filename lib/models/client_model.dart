import 'dart:io';

import 'package:uuid/uuid.dart';

class ClientModel{
  final Socket _socket;
  final String _topic;
  final String _name;
  final String? _id;
  final double? _lat;
  final double? _long;

  const ClientModel({
    required Socket socket,
    required String topic,
    required String name,
    String? id,
    required double? lat,
    required double? long,
  })  : _socket = socket
        _topic = topic,
        _name = name,
        _id = id,
        _lat = lat,
        _long = long;

  String get name => _name;

  Socket get socket => _socket;


  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      topic: map['topic'] as String,
      name: map['name'] as String,
      id: map['id'] as String,
      lat: map['lat'] as double,
      long: map['long'] as double,
    );
  }
}