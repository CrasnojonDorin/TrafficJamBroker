import 'location_model.dart';

class UpdatedLocation{
  final String topic;
  final LocationModel location;
  final String id;

  const UpdatedLocation({
    this.topic = 'update',
    required this.location,
    required this.id,
  });

  Map<String, dynamic> toMap({double? velocity}) {
    return {
      'location': location.toMap(),
      'velocity': velocity.toString(),
      'id': id,
    };
  }

  factory UpdatedLocation.fromMap(Map<String, dynamic> map) {
    return UpdatedLocation(
      location: LocationModel.fromMap(map['location']),
      id: map['id'] as String,
    );
  }
}