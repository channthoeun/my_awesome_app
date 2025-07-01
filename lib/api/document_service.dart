import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_awesome_app/api/api_exceptions.dart';
import 'package:my_awesome_app/utils/api_endpoints.dart';

class DocumentService {
  /// Uploads a document using a multipart request.
  ///
  /// Requires the [file] to upload and a valid [token].
  /// Throws [UnauthorizedException] on 401/403 errors.
  /// Throws [ApiException] on other errors.
  Future<String> uploadDocument(File file, String token) async {
    final url = Uri.parse(ApiEndpoints.documentUpload);

    try {
      // Create a multipart request
      final request = http.MultipartRequest('POST', url);

      // Add the authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Attach the file. The field name 'file' must match what your backend expects.
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // The API endpoint's expected field name for the file
          file.path,
        ),
      );

      // Send the request and wait for the response
      final streamedResponse = await request.send();

      // We need to manually handle the status code here since we're not using ApiClient
      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        // Read the response body for a success message from the server
        final responseBody = await streamedResponse.stream.bytesToString();
        return "Upload successful: $responseBody";
      } else if (streamedResponse.statusCode == 401 || streamedResponse.statusCode == 403) {
        throw UnauthorizedException('Your session has expired. Please log in again.');
      } else {
        throw ApiException('Failed to upload document. Status code: ${streamedResponse.statusCode}');
      }
    } on SocketException {
      throw ApiException('No Internet connection. Could not upload document.');
    } catch (e) {
      // Re-throw any exception that isn't already handled
      rethrow;
    }
  }
}