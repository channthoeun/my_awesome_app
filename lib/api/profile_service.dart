import 'package:my_awesome_app/models/user_model.dart';

class ProfileService {
  // Simulate fetching a user profile
  Future<User> getProfile(String token) async {
    await Future.delayed(const Duration(seconds: 1));

    if (token == 'fake_auth_token_for_user_123') {
      // Return mock user data
      return User.fromJson({
        'id': '123',
        'name': 'Flutter Developer',
        'email': 'test@test.com',
      });
    } else {
      throw Exception('Invalid token');
    }
  }
}