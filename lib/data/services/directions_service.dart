import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsService {
  static const String _apiKey = "AIzaSyB3OGmcoQQkpL5s1Enzf3D0rGlYgnIUFnU";

  /// Fetches a detailed coordinate path between two points.
  /// If the API fails, it falls back to a straight line for safety.
  static Future<List<LatLng>> getRoute(LatLng origin, LatLng destination) async {
    final PolylinePoints polylinePoints = PolylinePoints(apiKey: _apiKey);
    
    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        return result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      }
    } catch (e) {
      print("Error fetching directions: $e");
    }

    // Fallback if API fails
    return [origin, destination];
  }
}
