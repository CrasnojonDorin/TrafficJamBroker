import 'dart:convert';

import 'configuration/server_config.dart';
import 'worker/worker.dart';

void main(List<String> arguments) {
  final server = ServerConfiguration();

  server.run();

  final connections = server.clients;

  final queue = server.queue;

  final worker = Worker(connections: connections, queue: queue);

   worker.notify();
}
