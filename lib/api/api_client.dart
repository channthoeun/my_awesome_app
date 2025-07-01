import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:my_awesome_app/api/api_exceptions.dart';
import 'package:my_awesome_app/utils/app_config.dart';

class ApiClient {
  final String _baseUrl = AppConfig.baseUrl;
  // Create a logger for this class
  final _log = Logger('ApiClient');

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    dynamic responseJson;
    try {
      final url = Uri.parse(_baseUrl + endpoint);
      _log.info('GET: $url'); // <-- Log the request
      final response = await http.get(url, headers: headers);
      responseJson = _handleResponse(response);
    } on SocketException {
      throw ApiException('No Internet connection');
    }
    return responseJson;
  }

  // You can add post, put, delete methods here following the same pattern

  Future<dynamic> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    dynamic responseJson;
    try {
      final url = Uri.parse(_baseUrl + endpoint);
      _log.info('POST: $url');
      _log.fine('Body: $body'); // Use a finer level for verbose data
      final response = await http.post(
        url,
        body: json.encode(body), // Encode the body to JSON
        headers: headers ?? {'Content-Type': 'application/json'},
      );
      responseJson = _handleResponse(response);
    } on SocketException {
      throw ApiException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _handleResponse(http.Response response) {
    _log.fine('Response: ${response.statusCode} | Body: ${response.body}');
    switch (response.statusCode) {
      case 200:
      case 201:
        return json.decode(response.body);
      case 400:
        throw ApiException('Bad request');
      case 401: // The key part for this request
      case 403:
        _log.warning('Unauthorized response for ${response.request?.url}'); // <-- Log important errors
        throw UnauthorizedException('Unauthorized: Your session has expired.');
      case 404:
        throw NotFoundException('Resource not found');
      case 500:
      default:
        _log.severe('Server Error ${response.statusCode} for ${response.request?.url}');
        throw ServerException('Server Error: ${response.statusCode}');
    }
  }
}