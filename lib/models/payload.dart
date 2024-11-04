import 'package:trafic_jam/models/enum_payload_topic.dart';

class Payload{
  final PayloadTopic topic;
  final dynamic data;

  const Payload({
    required this.topic,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'topic': topic.name,
      'data': data,
    };
  }

}