import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

class ThreadSafeQueue<T> {
  late Isolate _isolate;
  late SendPort _sendPort;
  final _receivePort = ReceivePort();
  late Future<void> _isInitialized;

  ThreadSafeQueue() {
    _isInitialized = _initialize();
  }

  Future<void> _initialize() async {
    final completer = Completer<SendPort>();
    _receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        completer.complete(_sendPort);
      }
    });
    _isolate = await Isolate.spawn(_queueIsolate, _receivePort.sendPort);
    await completer.future;
  }

  static void _queueIsolate(SendPort sendPort) {
    final queue = Queue();
    final receivePort = ReceivePort();

    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      if (message is List && message.length == 2) {
        final command = message[0];
        final data = message[1];

        if (command == 'enqueue') {
          queue.addLast(data); // Add item to queue directly
        } else if (command == 'dequeue') {
          final replyPort = data as SendPort;
          if (queue.isNotEmpty) {
            replyPort.send(queue.removeFirst());
          } else {
            replyPort.send(null);
          }
        }
      }
    });
  }

  Future<void> enqueue(T item) async {
    await _isInitialized;
    _sendPort.send(['enqueue', item]); // Send item directly to be enqueued
  }

  Future<T?> dequeue() async {
    await _isInitialized;
    final responsePort = ReceivePort();
    _sendPort.send(['dequeue', responsePort.sendPort]);
    return await responsePort.first as T?;
  }

  void dispose() {
    _isolate.kill(priority: Isolate.immediate);
    _receivePort.close();
  }
}
