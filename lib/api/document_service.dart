import 'dart:io';

class DocumentService {
  // Simulate uploading a document
  Future<String> uploadDocument(File file, String token) async {
    await Future.delayed(const Duration(seconds: 2));

    if (token.isNotEmpty) {
      // In a real app, you would use http.MultipartRequest here
      print('Uploading ${file.path}...');
      return "Document '${file.path.split('/').last}' uploaded successfully!";
    } else {
      throw Exception('Authentication required');
    }
  }
}