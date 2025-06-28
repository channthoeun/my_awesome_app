import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_awesome_app/utils/app_config.dart';

class AuthService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<String> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/auth/token');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
        if (accessToken != null) {
          return accessToken;
        } else {
          throw Exception('Access token not found in response.');
        }
      } else {
        throw Exception('Failed to login. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred during login.');
    }
  }
}