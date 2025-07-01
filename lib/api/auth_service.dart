import 'package:logging/logging.dart';
import 'package:my_awesome_app/api/api_client.dart';
import 'package:my_awesome_app/utils/api_endpoints.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Logs the user in and returns the access token.
  ///
  /// Throws [ApiException] or its subtypes on API errors.
  Future<String> login(String username, String password) async {
    try {
      // Use the new post method from our ApiClient
      final response = await _apiClient.post(
        ApiEndpoints.login,
        body: {
          'username': username,
          'password': password,
        },
      );

      // The response is already a Map<String, dynamic> thanks to ApiClient
      final accessToken = response['access_token'];
      if (accessToken != null) {
        return accessToken;
      } else {
        // This case is unlikely if the API is well-behaved, but good for safety
        throw Exception('Access token not found in login response.');
      }
    } catch (e) {
      // Re-throw the structured exception for the UI to handle
      rethrow;
    }
  }
}