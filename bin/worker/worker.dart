import 'dart:convert';
import 'dart:developer';
import '../controller/threade_safe_queue.dart';
import '../models/updated_location.dart';
import '../models/connection_info.dart';

class Worker {
  final List<ConnectionInfo> connections;
  final ThreadSafeQueue<UpdatedLocation> queue;

  const Worker({
    required this.connections,
    required this.queue,
  });

  Future<void> notify() async {
    try {
      while (true) {
        final data = await queue.dequeue();

        //print('Dequeue $data');

        if (data != null) {

          log(data.location.toMap().toString());

          for (var element in connections) {
            if(element.id != data.id){
            element.socket.write(jsonEncode(data.toMap()));}
          }
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e, s) {
      print('NotifyError $e $s');
    }
  }
}
