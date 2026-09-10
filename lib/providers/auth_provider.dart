import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../data/models/user_model.dart';
import '../data/services/firebase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;

    if (isLoggedIn) {
      final email = prefs.getString(AppConstants.keyUserEmail) ?? 'rider@vybecabs.io';
      final name = prefs.getString(AppConstants.keyUserName) ?? 'Vicky Patel';
      final phone = prefs.getString(AppConstants.keyUserPhone) ?? '+91 98765 43210';
      _currentUser = UserModel(
        uid: 'saved_session_user',
        email: email,
        displayName: name,
        phoneNumber: phone,
      );
      notifyListeners();
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    clearError();
    _setLoading(true);
    try {
      _currentUser = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _persistSession(_currentUser!);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    clearError();
    _setLoading(true);
    try {
      _currentUser = await _authService.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      await _persistSession(_currentUser!);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> loginWithPhoneOtp(String phoneNumber, String otp) async {
    clearError();
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 900));
    _currentUser = UserModel(
      uid: 'usr_otp_${DateTime.now().millisecondsSinceEpoch}',
      email: 'phone.user@vybecabs.io',
      displayName: 'Vybe Traveler',
      phoneNumber: phoneNumber,
    );
    await _persistSession(_currentUser!);
    _setLoading(false);
    return true;
  }

  Future<bool> loginWithDemoMode() async {
    clearError();
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = await _authService.signInWithDemoMode();
    await _persistSession(_currentUser!);
    _setLoading(false);
    return true;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> _persistSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setString(AppConstants.keyUserEmail, user.email);
    await prefs.setString(AppConstants.keyUserName, user.displayName);
    await prefs.setString(AppConstants.keyUserPhone, user.phoneNumber);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
