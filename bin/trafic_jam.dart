import 'dart:convert';

import 'package:trafic_jam/configuration/server_config.dart';
import 'package:trafic_jam/worker/traffic_analyzer_worker.dart';

void main(List<String> arguments) {
  final server = ServerConfiguration();

  server.run();

  final connections = server.clients;

  final queue = server.queue;

  final worker = Worker(connections: connections, queue: queue);

   worker.notify();
}
