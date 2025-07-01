import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:my_awesome_app/api/auth_service.dart';
import 'package:my_awesome_app/api/profile_service.dart';
import 'package:my_awesome_app/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final _log = Logger('AuthProvider'); // <-- Create logger

  // --- STATE ---
  // The only pieces of state we need are the token and the user object.
  String? _token;
  User? _user;

  // --- SERVICES ---
  final _storage = const FlutterSecureStorage();
  final _authService = AuthService();
  final _profileService = ProfileService();

  // --- GETTERS ---
  bool get isAuthenticated => _token != null && _user != null;
  String? get token => _token;
  User? get user => _user;

  /// Logs the user in by getting a token and then fetching the user profile.
  Future<void> login(String username, String password) async {
    _log.info('Attempting login for user: $username');
    try {
      // 1. Get ONLY the access token from the auth service.
      final token = await _authService.login(username, password);
      _token = token;
      _log.config('Login successful, token received.'); // Use config for setup info

      // 2. Persist the token to secure storage.
      await _storage.write(key: 'authToken', value: _token);

      // 3. Fetch the user's profile using the newly acquired token.
      await _fetchUserProfile();

      // 4. Notify listeners to rebuild the UI (e.g., navigate to home screen).
      notifyListeners();
    } catch (e, stackTrace) {
      _log.severe('Login failed for user: $username', e, stackTrace); // <-- Log errors with stack trace
      // If anything fails, re-throw the exception to be caught by the LoginScreen.
      rethrow;
    }
  }

  /// Fetches the user profile using the current token.
  /// This is used both after login and during auto-login.
  Future<void> _fetchUserProfile() async {
    if (_token != null) {
      try {
        // We only need to pass the token to the profile service.
        _user = await _profileService.getProfile(_token!);
      } catch (e) {
        // If fetching the profile fails (e.g., token expired),
        // treat it as a full logout to clear the invalid state.
        print('Failed to fetch profile: $e. Logging out.');
        await logout();
        // Optionally rethrow to signal the failure upstream if needed
        // rethrow;
      }
    }
  }

  /// Attempts to automatically log in the user at app startup.
  Future<bool> tryAutoLogin() async {
    _log.info('Attempting auto-login...');
    // 1. Read the token from secure storage.
    final token = await _storage.read(key: 'authToken');
    if (token == null) {
      return false; // No token found, can't log in.
    }
    _token = token;

    // 2. Try to fetch the user profile with the stored token.
    await _fetchUserProfile();

    // 3. Notify listeners. If _fetchUserProfile was successful, `isAuthenticated` will be true.
    notifyListeners();

    // Return the final authentication status.
    return isAuthenticated;
  }

  /// Logs the user out by clearing all session data.
  Future<void> logout() async {
    _log.info('User logged out.');
    _token = null;
    _user = null;

    // Only need to delete the token from storage.
    await _storage.delete(key: 'authToken');

    notifyListeners();
  }
}