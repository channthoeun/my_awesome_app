import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:my_awesome_app/api/auth_service.dart';
import 'package:my_awesome_app/api/location_service.dart'; // <-- 1. Import the LocationService
import 'package:my_awesome_app/api/profile_service.dart';
import 'package:my_awesome_app/models/user_model.dart';

/// Manages the application-wide authentication state.
///
/// This provider handles user login, logout, session persistence (auto-login),
/// and fetching user profile data upon successful authentication.
class AuthProvider with ChangeNotifier {
  final _log = Logger('AuthProvider');

  // --- STATE ---
  String? _token;
  User? _user;

  // --- SERVICES ---
  final _storage = const FlutterSecureStorage();
  final _authService = AuthService();
  final _profileService = ProfileService();
  final _locationService = LocationService(); // <-- 2. Instantiate the LocationService

  // --- GETTERS ---
  /// Returns true if the user is authenticated (has a token and user object).
  bool get isAuthenticated => _token != null && _user != null;
  /// The current user's authentication token. Returns null if not logged in.
  String? get token => _token;
  /// The current user's profile data. Returns null if not logged in.
  User? get user => _user;

  /// Logs the user in by getting a token and then fetching the user profile.
  /// Also captures and logs the user's location data during the login attempt.
  Future<void> login(String username, String password) async {
    _log.info('Attempting login for user: $username');

    // --- 3. USE THE LOCATION SERVICE ---
    // This is a "fire and forget" call for logging purposes. We wrap it in a
    // try-catch so that a failure to get location data does not prevent the user
    // from being able to log in.
    try {
      final locationData = await _locationService.getCurrentLocationData();
      _log.info('Login attempt from: $locationData');
    } catch (e, s) {
      _log.warning('Could not retrieve location data during login.', e, s);
    }
    // --- END of location logic ---

    try {
      // The rest of the login logic proceeds as normal.
      final token = await _authService.login(username, password);
      _token = token;
      _log.config('Login successful, token received.');

      await _storage.write(key: 'authToken', value: _token);
      await _fetchUserProfile();

      notifyListeners();
    } catch (e, stackTrace) {
      _log.severe('Login failed for user: $username', e, stackTrace);
      rethrow; // Re-throw the exception to be displayed on the LoginScreen
    }
  }

  /// Fetches the user profile using the current token.
  /// This is used both after a fresh login and during auto-login.
  Future<void> _fetchUserProfile() async {
    if (_token != null) {
      try {
        _user = await _profileService.getProfile(_token!);
        _log.info('Successfully fetched profile for user: ${_user?.username}');
      } catch (e, s) {
        _log.severe('Failed to fetch profile, logging out.', e, s);
        // If fetching the profile fails (e.g., token expired),
        // treat it as a full logout to clear the invalid state.
        await logout();
      }
    }
  }

  /// Attempts to automatically log in the user at app startup by reading
  /// the token from secure storage.
  Future<bool> tryAutoLogin() async {
    _log.info('Attempting auto-login...');

    final token = await _storage.read(key: 'authToken');
    if (token == null) {
      _log.info('No token found in storage for auto-login.');
      return false;
    }
    _token = token;

    await _fetchUserProfile();

    // Notify listeners to update the UI based on the outcome of _fetchUserProfile.
    notifyListeners();

    _log.info('Auto-login finished. IsAuthenticated: $isAuthenticated');
    return isAuthenticated;
  }

  /// Logs the user out by clearing all session data and notifying listeners.
  Future<void> logout() async {
    _log.info('User logged out.');
    _token = null;
    _user = null;

    await _storage.delete(key: 'authToken');

    notifyListeners();
  }
}