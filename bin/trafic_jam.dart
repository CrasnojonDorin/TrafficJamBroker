import 'dart:isolate';
import 'package:trafic_jam/broker/broker_socket.dart';
import 'package:trafic_jam/worker/worker.dart';

void main(List<String> arguments) {
  final server = BrokerSocket();

  server.run();

  final updateLocationWorker = Worker();

  updateLocationWorker.notify();
}
