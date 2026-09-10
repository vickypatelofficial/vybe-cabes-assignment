class DriverModel {
  final String id;
  final String name;
  final double rating;
  final int totalTrips;
  final String carModel;
  final String plateNumber;
  final String phone;
  final String avatarUrl;
  final String badge;
  final List<String> languages;
  final String otp;

  const DriverModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.totalTrips,
    required this.carModel,
    required this.plateNumber,
    required this.phone,
    required this.avatarUrl,
    this.badge = 'Vybe Top Driver',
    this.languages = const ['English', 'Hindi'],
    this.otp = '8492',
  });

  String get photoUrl => avatarUrl;
  String get vehiclePlate => plateNumber;

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Driver',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      totalTrips: json['total_trips'] as int? ?? 1200,
      carModel: json['car_model'] as String? ?? 'Sedan',
      plateNumber: json['plate_number'] as String? ?? 'DL 01 AB 1234',
      phone: json['phone'] as String? ?? '+91 9876543210',
      avatarUrl: json['avatar_url'] as String? ?? '',
      badge: json['badge'] as String? ?? 'Vybe Top Driver',
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['English', 'Hindi'],
      otp: json['otp'] as String? ?? '8492',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'total_trips': totalTrips,
      'car_model': carModel,
      'plate_number': plateNumber,
      'phone': phone,
      'avatar_url': avatarUrl,
      'badge': badge,
      'languages': languages,
      'otp': otp,
    };
  }
}
