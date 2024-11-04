import 'dart:convert';
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

          Map<String, dynamic> map = data.location.toMap();

          final index = connections.indexWhere((element) => element.client.id == data.id);

          connections[index].client.setVelocity(time: DateTime.now(), newLocation: data.location);

          map.addAll({
            "velocity": connections[index].client.velocity.toString(),
            "name": connections[index].client.name,
            "id":connections[index].client.id
          });

          for (var element in connections) {
            if(element.client.id != data.id){
            element.socket.write(jsonEncode(
               map
            ));}else{
              element.socket.write('Speed: ${connections[index].client.velocity?.toStringAsFixed(2)} km/h');
            }
          }
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e, s) {
      print('NotifyError $e $s');
    }
  }
}
