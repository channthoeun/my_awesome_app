class AuthService {
  // Simulate a login API call
  Future<String> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'test@test.com' && password == 'password') {
      // On success, return a fake token
      return 'fake_auth_token_for_user_123';
    } else {
      // On failure, throw an error
      throw Exception('Invalid credentials');
    }
  }
}