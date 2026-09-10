import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppConstants {
  static const String appName = 'Vybe Cabs';
  static const String appTagline = 'Move with the Vybe';
  static const String appVersion = '1.0.0';

  // Default Center (New Delhi Connaught Place / Cyber City)
  static const LatLng defaultLocation = LatLng(28.6139, 77.2090);
  static const LatLng cyberCityLocation = LatLng(28.4986, 77.0898);

  // Session keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyUserPhone = 'user_phone';
}
