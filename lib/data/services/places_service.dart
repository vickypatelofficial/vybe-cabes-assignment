import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';

class PlacesService {
  static const String _apiKey = "AIzaSyB3OGmcoQQkpL5s1Enzf3D0rGlYgnIUFnU";
  static const String _autocompleteUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json";
  static const String _detailsUrl = "https://maps.googleapis.com/maps/api/place/details/json";

  static Future<List<LocationModel>> getSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final url = Uri.parse("$_autocompleteUrl?input=$query&key=$_apiKey&components=country:in");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions.map((p) {
            final mainText = p['structured_formatting']?['main_text'] ?? p['description'] ?? '';
            final secondaryText = p['structured_formatting']?['secondary_text'] ?? '';
            
            return LocationModel(
              id: p['place_id'],
              name: mainText,
              address: secondaryText,
              city: secondaryText, // Basic mapping
              latitude: 0, // Needs details fetch
              longitude: 0,
              type: 'search',
              icon: 'place',
            );
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print("Places autocomplete error: $e");
      return [];
    }
  }

  static Future<LocationModel?> getPlaceDetails(LocationModel location) async {
    // If it's already a full location (from mock data), just return it
    if (location.latitude != 0 && location.longitude != 0) {
      return location;
    }

    try {
      final url = Uri.parse("$_detailsUrl?place_id=${location.id}&key=$_apiKey");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final locationData = result['geometry']['location'];
          
          return LocationModel(
            id: location.id,
            name: location.name,
            address: location.address,
            city: location.city,
            latitude: locationData['lat'],
            longitude: locationData['lng'],
            type: location.type,
            icon: location.icon,
          );
        }
      }
      return location;
    } catch (e) {
      print("Place details error: $e");
      return location;
    }
  }
}
