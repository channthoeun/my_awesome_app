import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_awesome_app/models/user_model.dart';
import 'package:my_awesome_app/utils/app_config.dart';

class ProfileService {
  final String _baseUrl = AppConfig.baseUrl;

  // This method only needs the token.
  // The backend uses the token to identify the user.
  Future<User> getProfile(String token) async {
    // IMPORTANT: Make sure your backend has this endpoint.
    final url = Uri.parse('$_baseUrl/api/user/me');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching the profile.');
    }
  }
}