import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class ApiService {
  static final String baseUrl = dotenv.env['BASE_API_URL']!;

  Future<String> uploadCsvFile() async {
    // Use file_picker to pick the CSV file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      // Get the picked file
      File file = File(result.files.single.path!);

      // Prepare the request to upload the file
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        return 'File uploaded successfully!';
      } else {
        throw Exception('Failed to upload file: ${response.statusCode}');
      }
    } else {
      throw Exception('No file selected');
    }
  }
}
