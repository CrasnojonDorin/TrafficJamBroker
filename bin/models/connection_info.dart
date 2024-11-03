import 'dart:io';

class ConnectionInfo{
  final Socket socket;
  final String id;

  const ConnectionInfo({
    required this.socket,
    required this.id,
  });
}