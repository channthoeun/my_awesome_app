class ApiEndpoints {
  // Private constructor to prevent instantiation
  ApiEndpoints._();

  // --- Authentication ---
  static const String auth = '/auth';
  static const String login = '$auth/token';
  static const String refreshToken = '$auth/refresh'; // Example for the future

  // --- API ---
  static const String api = '/api';

  // --- User Profile ---
  static const String user = '$api/user';
  static const String userProfile = '$user/me';

  // --- Pet Management ---
  static const String pet = '$api/pet';
  static String petDetail(String petId) => '$pet/$petId'; // Dynamic endpoint

  // --- Document Management ---
  static const String documentUpload = '/documents/upload';
}