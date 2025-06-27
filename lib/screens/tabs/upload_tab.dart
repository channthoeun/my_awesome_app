import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_awesome_app/api/document_service.dart';
import 'package:my_awesome_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class UploadTab extends StatefulWidget {
  const UploadTab({super.key});

  @override
  State<UploadTab> createState() => _UploadTabState();
}

class _UploadTabState extends State<UploadTab> {
  final DocumentService _documentService = DocumentService();
  File? _pickedFile;
  bool _isUploading = false;
  String? _uploadMessage;

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
        _uploadMessage = null; // Clear previous messages
      });
    }
  }

  Future<void> _uploadDocument() async {
    if (_pickedFile == null) return;
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    setState(() {
      _isUploading = true;
      _uploadMessage = null;
    });

    try {
      final message = await _documentService.uploadDocument(_pickedFile!, token);
      setState(() {
        _uploadMessage = message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() {
        _uploadMessage = 'Upload failed: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _pickDocument,
              icon: const Icon(Icons.attach_file),
              label: const Text('Pick a Document'),
            ),
            const SizedBox(height: 20),
            if (_pickedFile != null)
              Text('Selected: ${_pickedFile!.path.split('/').last}'),
            const SizedBox(height: 20),
            if (_isUploading)
              const CircularProgressIndicator()
            else if (_pickedFile != null)
              ElevatedButton.icon(
                onPressed: _uploadDocument,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload Document'),
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
              ),
          ],
        ),
      ),
    );
  }
}