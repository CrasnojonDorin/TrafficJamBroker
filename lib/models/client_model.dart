import 'dart:io';
import 'package:traffic_jam_broker/models/location_model.dart';

class ClientModel {
  final Socket? _socket;
  final String _topic;
  final String _name;
  final String? _id;
  final LocationModel? _location;

  const ClientModel(
      {Socket? socket,
      required String topic,
      required String name,
      String? id,
      LocationModel? location})
      : _socket = socket,
        _topic = topic,
        _name = name,
        _id = id,
        _location = location;

  String get name => _name;

  Socket? get socket => _socket;

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      topic: map['topic'] as String,
      name: map['name'] as String,
      id: map['id'] as String,
      location: LocationModel.fromMap(map['location']) as LocationModel?,
    );
  }
}
