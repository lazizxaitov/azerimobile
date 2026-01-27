class PickupPoint {
  const PickupPoint({
    required this.id,
    required this.title,
    required this.address,
    required this.phone,
    required this.workHours,
    required this.lat,
    required this.lng,
  });

  final int id;
  final String title;
  final String address;
  final String phone;
  final String workHours;
  final double lat;
  final double lng;

  factory PickupPoint.fromJson(Map<String, dynamic> json) {
    return PickupPoint(
      id: _asInt(json['id']),
      title: _asString(json['title']),
      address: _asString(json['address']),
      phone: _asString(json['phone']),
      workHours: _asString(json['work_hours']),
      lat: _asDouble(json['lat']),
      lng: _asDouble(json['lng']),
    );
  }
}

int _asInt(Object? value) => value is num ? value.toInt() : 0;

double _asDouble(Object? value) => value is num ? value.toDouble() : 0.0;

String _asString(Object? value) => value?.toString() ?? '';
