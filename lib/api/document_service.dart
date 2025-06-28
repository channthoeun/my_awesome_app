import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_awesome_app/utils/app_config.dart';

class DocumentService {
  final String _baseUrl = AppConfig.baseUrl;

  Future<String> uploadDocument(File file, String token) async {
    final url = Uri.parse('$_baseUrl/documents/upload');
    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        final responseBody = await streamedResponse.stream.bytesToString();
        return "Upload successful: $responseBody";
      } else {
        throw Exception('Failed to upload document. Status code: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred during file upload.');
    }
  }
}