import 'location_model.dart';
import 'package:uuid/uuid.dart';

class ClientModel {
  final String name;
  final String phone;
  final String id;
  final LocationModel? location;

  ClientModel(
      { required this.name, required this.phone, this.location})
      : id = const Uuid().v5(Uuid.NAMESPACE_URL, name);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'id': id,
      'location': location?.toMap(),
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      name: map['name'] as String,
      phone: map['phone'] as String,
      location: LocationModel.fromMap(map['location']),
    );
  }
}
