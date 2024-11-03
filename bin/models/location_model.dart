class LocationModel{
  final double? lat;
  final double? long;
  final String? address;

  const LocationModel({
    this.lat,
    this.long,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'long': long,
      'address': address,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      lat: map['lat'] as double?,
      long: map['long'] as double?,
      address: map['address'] as String?,
    );
  }
}