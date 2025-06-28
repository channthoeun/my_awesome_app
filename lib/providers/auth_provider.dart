import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_awesome_app/api/auth_service.dart';
import 'package:my_awesome_app/api/profile_service.dart';
import 'package:my_awesome_app/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  User? _user;
  final _storage = const FlutterSecureStorage();
  final _authService = AuthService();
  final _profileService = ProfileService();

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  User? get user => _user;

  Future<void> login(String username, String password) async {
    try {
      final token = await _authService.login(username, password);
      _token = token;
      await _storage.write(key: 'authToken', value: _token);
      await _fetchUserProfile();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _fetchUserProfile() async {
    if (_token != null) {
      try {
        // We only need to pass the token
        _user = await _profileService.getProfile(_token!);
      } catch (e) {
        await logout();
      }
    }
  }

  Future<bool> tryAutoLogin() async {
    final token = await _storage.read(key: 'authToken');
    if (token == null) {
      return false;
    }
    _token = token;
    await _fetchUserProfile();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _storage.delete(key: 'authToken');
    notifyListeners();
  }
}