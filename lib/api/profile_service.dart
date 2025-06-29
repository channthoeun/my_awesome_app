import 'package:my_awesome_app/api/api_client.dart';
import 'package:my_awesome_app/models/user_model.dart';
import 'package:my_awesome_app/utils/api_endpoints.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches the detailed profile of the currently logged-in user.
  ///
  /// Requires a valid [token] for authorization.
  /// Throws [UnauthorizedException] if the token is invalid/expired.
  /// Throws other [ApiException] subtypes on other errors.
  Future<User> getProfile(String token) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.userProfile,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // ApiClient returns a Map<String, dynamic>, which is perfect
      // for our fromJson factory.
      return User.fromJson(response);
    } catch (e) {
      // Re-throw for the AuthProvider or UI layer to handle
      rethrow;
    }
  }
}