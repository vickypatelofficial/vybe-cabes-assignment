import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String type;
  final String icon;

  const LocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.icon,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? 'general',
      icon: json['icon'] as String? ?? 'place',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'icon': icon,
    };
  }
}
