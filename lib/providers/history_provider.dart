import 'package:flutter/material.dart';
import '../data/mock/mock_data.dart';
import '../data/models/trip_model.dart';

enum RideFilter { all, completed, cancelled }

class HistoryProvider extends ChangeNotifier {
  List<TripModel> _trips = [];
  RideFilter _currentFilter = RideFilter.all;

  List<TripModel> get allTrips => _trips;
  RideFilter get currentFilter => _currentFilter;

  List<TripModel> get filteredTrips {
    switch (_currentFilter) {
      case RideFilter.completed:
        return _trips.where((t) => t.status == TripStatus.completed).toList();
      case RideFilter.cancelled:
        return _trips.where((t) => t.status == TripStatus.cancelled).toList();
      case RideFilter.all:
        return _trips;
    }
  }

  HistoryProvider() {
    _trips = MockData.getPastRides();
  }

  void setFilter(RideFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void addTrip(TripModel trip) {
    _trips.insert(0, trip);
    notifyListeners();
  }
}
