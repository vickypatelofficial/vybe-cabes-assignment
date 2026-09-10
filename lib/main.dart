import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/splash/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/history_provider.dart';
import 'providers/tracking_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyDemoDummyApiKeyForEvaluation123',
          appId: '1:1234567890:web:abcdef123456',
          messagingSenderId: '1234567890',
          projectId: 'vybe-cabs-demo',
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const VybeCabsApp());
}

class VybeCabsApp extends StatelessWidget {
  const VybeCabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => TrackingProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: MaterialApp(
        title: 'Vybe Cabs',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
