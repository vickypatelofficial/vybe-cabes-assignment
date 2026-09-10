import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeoUtils {
  static double calculateDistanceKm(LatLng start, LatLng end) {
    const double earthRadiusKm = 6371.0;
    final double dLat = _degreesToRadians(end.latitude - start.latitude);
    final double dLng = _degreesToRadians(end.longitude - start.longitude);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double calculateBearing(LatLng start, LatLng end) {
    final double startLat = _degreesToRadians(start.latitude);
    final double startLng = _degreesToRadians(start.longitude);
    final double endLat = _degreesToRadians(end.latitude);
    final double endLng = _degreesToRadians(end.longitude);

    final double dLng = endLng - startLng;

    final double y = sin(dLng) * cos(endLat);
    final double x = cos(startLat) * sin(endLat) -
        sin(startLat) * cos(endLat) * cos(dLng);

    final double radians = atan2(y, x);
    final double degrees = (radians * 180 / pi + 360) % 360;
    return degrees;
  }

  static LatLng interpolate(LatLng from, LatLng to, double t) {
    final double lat = from.latitude + (to.latitude - from.latitude) * t;
    final double lng = from.longitude + (to.longitude - from.longitude) * t;
    return LatLng(lat, lng);
  }

  static String formatDistance(double km) {
    if (km < 1.0) {
      final int meters = (km * 1000).round();
      return '${meters}m';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes mins';
    }
    final int hours = minutes ~/ 60;
    final int remainingMins = minutes % 60;
    if (remainingMins == 0) {
      final String suffix = hours > 1 ? 'hrs' : 'hr';
      return '$hours $suffix';
    }
    return '$hours hr $remainingMins min';
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
