class RideOptionModel {
  final String id;
  final String title;
  final String tagline;
  final int capacity;
  final double baseFare;
  final double perKmRate;
  final int etaMinutes;
  final String iconType;
  final double multiplier;
  final bool isPopular;

  const RideOptionModel({
    required this.id,
    required this.title,
    required this.tagline,
    required this.capacity,
    required this.baseFare,
    required this.perKmRate,
    required this.etaMinutes,
    required this.iconType,
    required this.multiplier,
    this.isPopular = false,
  });

  String get name => title;
  String get etaMin => '$etaMinutes min away';

  String get iconEmoji {
    switch (id) {
      case 'vybe_mini':
        return '🚗';
      case 'vybe_prime':
        return '⚡';
      case 'vybe_premier':
        return '✨';
      case 'vybe_xl':
        return '🚙';
      case 'vybe_auto':
        return '🛺';
      default:
        return '🚘';
    }
  }

  double calculateFare(double distanceKm) {
    final double fare = baseFare + (distanceKm * perKmRate);
    return (fare * multiplier).roundToDouble();
  }

  factory RideOptionModel.fromJson(Map<String, dynamic> json) {
    return RideOptionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      capacity: json['capacity'] as int? ?? 4,
      baseFare: (json['base_fare'] as num?)?.toDouble() ?? 50.0,
      perKmRate: (json['per_km_rate'] as num?)?.toDouble() ?? 15.0,
      etaMinutes: json['eta_minutes'] as int? ?? 3,
      iconType: json['icon_type'] as String? ?? 'car_sedan',
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      isPopular: json['is_popular'] as bool? ?? false,
    );
  }
}
