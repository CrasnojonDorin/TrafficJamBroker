import 'dart:io';

import 'client_model.dart';

class ConnectionInfo{
  final Socket socket;
  ClientModel? client;

   ConnectionInfo({
    required this.socket,
  });
}