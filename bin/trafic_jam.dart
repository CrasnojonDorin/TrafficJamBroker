import 'dart:collection';
import 'dart:convert';
import 'dart:isolate';

import 'package:trafic_jam/configuration/server_config.dart';
import 'package:trafic_jam/storage/payload_storage.dart';
import 'package:trafic_jam/worker/worker.dart';

void main(List<String> arguments) {
  final server = ServerConfiguration();

  server.run();

  final receivePort = ReceivePort();

  // PayloadStorage.setWorkerSendPort(receivePort.sendPort);

  final updateLocationWorker = Worker();

  updateLocationWorker.notify();
}
