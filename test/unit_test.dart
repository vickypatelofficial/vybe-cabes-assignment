import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vybe_cabs/core/utils/geo_utils.dart';
import 'package:vybe_cabs/data/mock/mock_data.dart';
import 'package:vybe_cabs/data/models/trip_model.dart';
import 'package:vybe_cabs/providers/booking_provider.dart';
import 'package:vybe_cabs/providers/history_provider.dart';

void main() {
  group('GeoUtils Tests', () {
    test('calculateDistanceKm returns correct non-zero distance', () {
      const p1 = LatLng(28.6139, 77.2090); // Connaught Place
      const p2 = LatLng(28.4986, 77.0898); // Cyber City
      final distance = GeoUtils.calculateDistanceKm(p1, p2);

      expect(distance, greaterThan(10.0));
      expect(distance, lessThan(25.0));
    });

    test('calculateBearing returns valid angle 0-360', () {
      const p1 = LatLng(28.6139, 77.2090);
      const p2 = LatLng(28.4986, 77.0898);
      final bearing = GeoUtils.calculateBearing(p1, p2);

      expect(bearing, greaterThanOrEqualTo(0.0));
      expect(bearing, lessThanOrEqualTo(360.0));
    });

    test('formatDistance formats meters and kilometers accurately', () {
      expect(GeoUtils.formatDistance(0.5), equals('500m'));
      expect(GeoUtils.formatDistance(5.23), equals('5.2 km'));
    });

    test('formatDuration formats minutes and hours cleanly', () {
      expect(GeoUtils.formatDuration(25), equals('25 mins'));
      expect(GeoUtils.formatDuration(60), equals('1 hr'));
      expect(GeoUtils.formatDuration(85), equals('1 hr 25 min'));
    });
  });

  group('BookingProvider Tests', () {
    late BookingProvider booking;

    setUp(() {
      booking = BookingProvider();
    });

    test('initial state has default pickup and 5 ride options', () {
      expect(booking.pickupLocation.name, isNotEmpty);
      expect(booking.availableRideOptions.length, equals(5));
      expect(booking.hasSelectedDestination, isFalse);
    });

    test('selecting drop location recalculates route metrics and estimated fare', () {
      final destination = MockData.popularLocations.first;
      booking.setDropLocation(destination);

      expect(booking.hasSelectedDestination, isTrue);
      expect(booking.distanceKm, greaterThan(0.0));
      expect(booking.estimatedDurationMin, greaterThan(0));

      final fare = booking.getCalculatedFare(booking.availableRideOptions.first);
      expect(fare, greaterThan(50));
    });

    test('reset clears destination and resets metrics', () {
      booking.setDropLocation(MockData.popularLocations.first);
      expect(booking.hasSelectedDestination, isTrue);

      booking.reset();
      expect(booking.hasSelectedDestination, isFalse);
      expect(booking.distanceKm, equals(0.0));
    });
  });

  group('HistoryProvider Tests', () {
    late HistoryProvider history;

    setUp(() {
      history = HistoryProvider();
    });

    test('preloads 6 past rides from dummy data', () {
      expect(history.allTrips.length, equals(6));
    });

    test('filters completed and cancelled rides accurately', () {
      history.setFilter(RideFilter.completed);
      expect(history.filteredTrips.every((t) => t.status == TripStatus.completed), isTrue);

      history.setFilter(RideFilter.cancelled);
      expect(history.filteredTrips.every((t) => t.status == TripStatus.cancelled), isTrue);

      history.setFilter(RideFilter.all);
      expect(history.filteredTrips.length, equals(6));
    });
  });

  group('Data Model Tests', () {
    test('DriverModel getters work properly', () {
      const driver = MockData.dummyDriver;
      expect(driver.photoUrl, equals(driver.avatarUrl));
      expect(driver.vehiclePlate, equals(driver.plateNumber));
      expect(driver.otp, equals('8492'));
    });

    test('RideOptionModel computes fare with multiplier', () {
      final option = MockData.rideOptions[1]; // Vybe Prime (80 base, 18/km, 1.25x)
      final fare = option.calculateFare(10.0); // (80 + 180) * 1.25 = 325
      expect(fare, equals(325.0));
    });
  });
}
