import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/utils/geo_utils.dart';
import '../data/mock/mock_data.dart';
import '../data/models/location_model.dart';
import '../data/models/ride_option_model.dart';

class BookingProvider extends ChangeNotifier {
  LocationModel _pickupLocation = MockData.defaultPickup;
  LocationModel? _dropLocation;
  final List<LocationModel> _popularLocations = MockData.popularLocations;
  final List<RideOptionModel> _rideOptions = MockData.rideOptions;
  RideOptionModel? _selectedRideOption;
  String _paymentMethod = 'UPI';
  double _distanceKm = 0.0;
  int _estimatedDurationMin = 0;

  LocationModel get pickupLocation => _pickupLocation;
  LocationModel? get dropLocation => _dropLocation;
  List<LocationModel> get popularLocations => _popularLocations;
  List<RideOptionModel> get rideOptions => _rideOptions;
  List<RideOptionModel> get availableRideOptions => _rideOptions;
  RideOptionModel? get selectedRideOption => _selectedRideOption ?? (_rideOptions.isNotEmpty ? _rideOptions[1] : null);
  String get paymentMethod => _paymentMethod;
  String get selectedPaymentMethod => _paymentMethod;
  double get distanceKm => _distanceKm;
  double? get routeDistanceKm => _distanceKm > 0 ? _distanceKm : null;
  int get estimatedDurationMin => _estimatedDurationMin;
  int? get estimatedMinutes => _estimatedDurationMin > 0 ? _estimatedDurationMin : null;
  bool get hasSelectedDestination => _dropLocation != null;

  BookingProvider() {
    _selectedRideOption = _rideOptions.length > 1 ? _rideOptions[1] : _rideOptions.first;
  }

  void setPickupLocation(LocationModel location) {
    _pickupLocation = location;
    _recalculateTripMetrics();
    notifyListeners();
  }

  void setPickupCoordinates(LatLng latLng, {String name = 'Current Location'}) {
    _pickupLocation = LocationModel(
      id: 'gps_pickup',
      name: name,
      address: 'Lat: ${latLng.latitude.toStringAsFixed(4)}, Lng: ${latLng.longitude.toStringAsFixed(4)}',
      city: 'Delhi NCR',
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      type: 'gps',
      icon: 'my_location',
    );
    _recalculateTripMetrics();
    notifyListeners();
  }

  void setDropLocation(LocationModel location) {
    _dropLocation = location;
    _recalculateTripMetrics();
    notifyListeners();
  }

  void selectRideOption(RideOptionModel option) {
    _selectedRideOption = option;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void clearDestination() {
    _dropLocation = null;
    _distanceKm = 0.0;
    _estimatedDurationMin = 0;
    notifyListeners();
  }

  void reset() {
    clearDestination();
  }

  void _recalculateTripMetrics() {
    if (_dropLocation != null) {
      _distanceKm = GeoUtils.calculateDistanceKm(
        _pickupLocation.latLng,
        _dropLocation!.latLng,
      );
      _estimatedDurationMin = ((_distanceKm * 2.2) + 4).round();
      if (_estimatedDurationMin < 5) _estimatedDurationMin = 5;
    }
  }

  double getEstimatedFare(RideOptionModel option) {
    return option.calculateFare(_distanceKm > 0 ? _distanceKm : 10.0);
  }

  int getCalculatedFare(RideOptionModel option) {
    return getEstimatedFare(option).round();
  }
}
