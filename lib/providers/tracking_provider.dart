import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/utils/geo_utils.dart';
import '../data/mock/mock_data.dart';
import '../data/models/driver_model.dart';
import '../data/services/directions_service.dart';
import '../data/models/location_model.dart';
import '../data/models/ride_option_model.dart';
import '../data/models/trip_model.dart';

class TrackingProvider extends ChangeNotifier {
  TripStatus _tripStatus = TripStatus.idle;
  TripModel? _activeTrip;
  DriverModel? _driver;
  
  LatLng? _driverLocation;
  double _driverBearing = 0.0;
  List<LatLng> _currentPath = [];
  int _pathIndex = 0;
  Timer? _movementTimer;
  
  int _driverEtaMinutes = 3;
  String _searchStatusText = 'Connecting with nearby Vybe drivers...';
  int _findingSecondsRemaining = 4;
  Timer? _findingTimer;

  TripStatus get tripStatus => _tripStatus;
  TripModel? get activeTrip => _activeTrip;
  TripModel? get currentTrip => _activeTrip;
  DriverModel? get driver => _driver;
  LatLng? get driverLocation => _driverLocation;
  double get driverBearing => _driverBearing;
  List<LatLng> get currentPath => _currentPath;
  int get driverEtaMinutes => _driverEtaMinutes;
  String get searchStatusText => _searchStatusText;
  int get findingSecondsRemaining => _findingSecondsRemaining;

  bool get isDriverHeadingToPickup => _tripStatus == TripStatus.driverArriving || _tripStatus == TripStatus.driverAssigned;
  bool get hasDriverArrived => _tripStatus == TripStatus.driverArrived;
  bool get isTripInProgress => _tripStatus == TripStatus.inProgress;
  bool get isTripCompleted => _tripStatus == TripStatus.completed;

  void startFindingDriver({
    required LocationModel pickup,
    required LocationModel drop,
    required RideOptionModel rideOption,
    required String paymentMethod,
  }) {
    _tripStatus = TripStatus.findingDriver;
    _driver = null;
    _driverLocation = null;
    _findingSecondsRemaining = 4;
    _searchStatusText = 'Scanning 14+ available drivers nearby...';
    notifyListeners();

    _findingTimer?.cancel();
    _findingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _findingSecondsRemaining--;
      if (_findingSecondsRemaining == 3) {
        _searchStatusText = 'Found high-rated driver nearby!';
        notifyListeners();
      } else if (_findingSecondsRemaining == 2) {
        _searchStatusText = 'Confirming driver reservation...';
        notifyListeners();
      } else if (_findingSecondsRemaining <= 0) {
        timer.cancel();
        _onDriverMatched(
          pickup: pickup,
          drop: drop,
          rideOption: rideOption,
          paymentMethod: paymentMethod,
        );
      }
    });
  }

  Future<void> _onDriverMatched({
    required LocationModel pickup,
    required LocationModel drop,
    required RideOptionModel rideOption,
    required String paymentMethod,
  }) async {
    _driver = MockData.dummyDriver;
    final double distanceKm = GeoUtils.calculateDistanceKm(pickup.latLng, drop.latLng);
    final double fare = rideOption.calculateFare(distanceKm);

    _activeTrip = TripModel(
      id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
      dateTime: 'Just now',
      pickup: pickup,
      drop: drop,
      fare: fare,
      distanceKm: distanceKm,
      durationMin: ((distanceKm * 2.2) + 4).round(),
      status: TripStatus.driverArriving,
      rideOption: rideOption,
      driver: _driver,
      paymentMethod: paymentMethod,
      fareBreakdown: FareBreakdown(
        baseFare: rideOption.baseFare,
        distanceFare: (fare - rideOption.baseFare).clamp(10.0, 9999.0),
        timeFare: 15.0,
        taxes: (fare * 0.05),
        discount: -20.0,
      ),
    );

    _tripStatus = TripStatus.driverArriving;
    _driverEtaMinutes = 3;

    // Simulate driver starting a bit away from the pickup point
    final dummyDriverStart = LatLng(pickup.latLng.latitude + 0.0095, pickup.latLng.longitude - 0.0075);
    _currentPath = await DirectionsService.getRoute(dummyDriverStart, pickup.latLng);
    
    _pathIndex = 0;
    _driverLocation = _currentPath.first;
    if (_currentPath.length > 1) {
      _driverBearing = GeoUtils.calculateBearing(_currentPath[0], _currentPath[1]);
    }
    notifyListeners();

    _startSimulatedMovement(
      stepDurationMs: 300,
      onDestinationReached: () {
        _onDriverArrivedAtPickup();
      },
      onStep: (index, total) {
        final remaining = total - index;
        if (remaining <= 2) {
          _driverEtaMinutes = 1;
        } else if (remaining <= 5) {
          _driverEtaMinutes = 2;
        } else {
          _driverEtaMinutes = 3;
        }
        notifyListeners();
      },
    );
  }

  void _onDriverArrivedAtPickup() {
    _tripStatus = TripStatus.driverArrived;
    _driverEtaMinutes = 0;
    if (_activeTrip != null) {
      _activeTrip = _activeTrip!.copyWith(status: TripStatus.driverArrived);
    }
    notifyListeners();
  }

  Future<void> startTripToDestination() async {
    if (_activeTrip == null) return;
    _tripStatus = TripStatus.inProgress;
    _activeTrip = _activeTrip!.copyWith(status: TripStatus.inProgress);
    notifyListeners();

    _currentPath = await DirectionsService.getRoute(
      _activeTrip!.pickup.latLng,
      _activeTrip!.drop.latLng,
    );
    _pathIndex = 0;
    _driverLocation = _currentPath.first;
    if (_currentPath.length > 1) {
      _driverBearing = GeoUtils.calculateBearing(_currentPath[0], _currentPath[1]);
    }
    notifyListeners();

    _startSimulatedMovement(
      stepDurationMs: 300,
      onDestinationReached: () {
        _onTripCompleted();
      },
      onStep: (index, total) {
        final remainingSteps = total - index;
        _driverEtaMinutes = (remainingSteps * 1.5).ceil();
        if (_driverEtaMinutes < 1) _driverEtaMinutes = 1;
        notifyListeners();
      },
    );
  }

  void _startSimulatedMovement({
    int stepDurationMs = 1200,
    required VoidCallback onDestinationReached,
    required void Function(int index, int total) onStep,
  }) {
    _movementTimer?.cancel();
    _movementTimer = Timer.periodic(Duration(milliseconds: stepDurationMs), (timer) {
      if (_pathIndex < _currentPath.length - 1) {
        _pathIndex++;
        final LatLng nextPos = _currentPath[_pathIndex];
        final LatLng prevPos = _currentPath[_pathIndex - 1];

        _driverBearing = GeoUtils.calculateBearing(prevPos, nextPos);
        _driverLocation = nextPos;
        onStep(_pathIndex, _currentPath.length);
        notifyListeners();
      } else {
        timer.cancel();
        onDestinationReached();
      }
    });
  }

  void _onTripCompleted() {
    _tripStatus = TripStatus.completed;
    if (_activeTrip != null) {
      _activeTrip = _activeTrip!.copyWith(status: TripStatus.completed);
    }
    notifyListeners();
  }

  void cancelBooking({String reason = 'Rider cancelled'}) {
    _movementTimer?.cancel();
    _findingTimer?.cancel();
    if (_activeTrip != null) {
      _activeTrip = _activeTrip!.copyWith(
        status: TripStatus.cancelled,
        cancellationReason: reason,
      );
    }
    _tripStatus = TripStatus.cancelled;
    notifyListeners();
  }

  void reset() {
    _movementTimer?.cancel();
    _findingTimer?.cancel();
    _tripStatus = TripStatus.idle;
    _activeTrip = null;
    _driver = null;
    _driverLocation = null;
    _currentPath = [];
    _pathIndex = 0;
    _driverEtaMinutes = 3;
    notifyListeners();
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    _findingTimer?.cancel();
    super.dispose();
  }
}
