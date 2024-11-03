import 'location_model.dart';

class UpdatedLocation{
  final LocationModel location;
  final String id;

  const UpdatedLocation({
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