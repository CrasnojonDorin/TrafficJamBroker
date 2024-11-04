import 'dart:isolate';

import '../controller/threade_safe_queue.dart';
import '../models/updated_location.dart';

abstract class PayloadStorage {
  static final queue = ThreadSafeQueue<UpdatedLocation>();

  static void add(UpdatedLocation location) async {
    await queue.enqueue(location);
    // Trimite mesaj către worker, dacă există
    if (_workerSendPort != null) {
      _workerSendPort!.send(location.toMap());
    }
  }

  static Future<UpdatedLocation?> getNext() async {
    return await queue.dequeue();
  }

  static SendPort? _workerSendPort;

  static void setWorkerSendPort(SendPort sendPort) {
    _workerSendPort = sendPort; // Setează SendPort-ul worker-ului
  }
}