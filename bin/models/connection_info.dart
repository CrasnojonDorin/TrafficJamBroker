import 'dart:io';

import 'client_model.dart';

class ConnectionInfo{
  final Socket socket;
  final ClientModel client;

  const ConnectionInfo({
    required this.socket,
    required this.client
  });
}