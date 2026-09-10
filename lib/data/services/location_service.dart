import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_constants.dart';

class LocationService {
  static Future<LatLng> getCurrentUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return AppConstants.defaultLocation;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return AppConstants.defaultLocation;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return AppConstants.defaultLocation;
      }

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 4),
      );

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return AppConstants.defaultLocation;
    }
  }
}
