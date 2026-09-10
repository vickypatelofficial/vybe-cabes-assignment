import 'driver_model.dart';
import 'location_model.dart';
import 'ride_option_model.dart';

enum TripStatus {
  idle,
  findingDriver,
  driverAssigned,
  driverArriving,
  driverArrived,
  inProgress,
  completed,
  cancelled,
}

class FareBreakdown {
  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double taxes;
  final double discount;

  const FareBreakdown({
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.taxes,
    required this.discount,
  });

  double get total => baseFare + distanceFare + timeFare + taxes + discount;
}

class TripModel {
  final String id;
  final String dateTime;
  final LocationModel pickup;
  final LocationModel drop;
  final double fare;
  final double distanceKm;
  final int durationMin;
  final TripStatus status;
  final RideOptionModel rideOption;
  final DriverModel? driver;
  final int rating;
  final String paymentMethod;
  final FareBreakdown fareBreakdown;
  final String? cancellationReason;

  const TripModel({
    required this.id,
    required this.dateTime,
    required this.pickup,
    required this.drop,
    required this.fare,
    required this.distanceKm,
    required this.durationMin,
    required this.status,
    required this.rideOption,
    this.driver,
    this.rating = 0,
    this.paymentMethod = 'Vybe Pay Wallet',
    required this.fareBreakdown,
    this.cancellationReason,
  });

  String get rideCategory => rideOption.name;
  String get formattedDate => dateTime;

  TripModel copyWith({
    String? id,
    String? dateTime,
    LocationModel? pickup,
    LocationModel? drop,
    double? fare,
    double? distanceKm,
    int? durationMin,
    TripStatus? status,
    RideOptionModel? rideOption,
    DriverModel? driver,
    int? rating,
    String? paymentMethod,
    FareBreakdown? fareBreakdown,
    String? cancellationReason,
  }) {
    return TripModel(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      pickup: pickup ?? this.pickup,
      drop: drop ?? this.drop,
      fare: fare ?? this.fare,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMin: durationMin ?? this.durationMin,
      status: status ?? this.status,
      rideOption: rideOption ?? this.rideOption,
      driver: driver ?? this.driver,
      rating: rating ?? this.rating,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      fareBreakdown: fareBreakdown ?? this.fareBreakdown,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
