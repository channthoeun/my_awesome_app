import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Use ?? to provide a fallback value if the variable is not in the .env file.
  static final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
}