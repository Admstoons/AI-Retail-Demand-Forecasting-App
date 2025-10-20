import 'dart:io' show File;
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:mime/mime.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:retry/retry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadResult {
  final String fileURL;
  final String filePath;

  UploadResult({required this.fileURL, required this.filePath});
}

class UploadService {
  final SupabaseClient _client = Supabase.instance.client;
  final String bucketName = 'models'; // change if needed

  /// ✅ Mobile Upload using File
  Future<UploadResult> uploadFile(File file) async {
    try {
      if (!file.existsSync()) {
        throw Exception('File does not exist: ${file.path}');
      }

      if (file.lengthSync() > 50 * 1024 * 1024) {
        throw Exception('File too large (max 50MB)');
      }

      if (!file.path.endsWith('.csv') && !file.path.endsWith('.json')) {
        throw Exception('Invalid file format: only CSV or JSON allowed');
      }

      final fileBytes = await file.readAsBytes();
      final fileName =
          'sales_data/${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      await retry(
        () => _client.storage
            .from(bucketName)
            .uploadBinary(
              fileName,
              fileBytes,
              fileOptions: FileOptions(contentType: mimeType, upsert: true),
            ),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
        onRetry: (e) => debugPrint('Retrying upload: $e'),
      );

      final publicUrl = _client.storage.from(bucketName).getPublicUrl(fileName);

      return UploadResult(fileURL: publicUrl, filePath: fileName);
    } catch (e, stack) {
      debugPrint('Upload Exception: $e');
      debugPrint('StackTrace: $stack');
      throw Exception('Supabase upload failed: $e');
    }
  }

  /// ✅ Web Upload using Uint8List + filename
  Future<UploadResult> uploadBytes(Uint8List bytes, String filename) async {
    try {
      if (bytes.isEmpty) {
        throw Exception('Cannot upload empty file.');
      }

      final fileName =
          'sales_data/${DateTime.now().millisecondsSinceEpoch}_$filename';
      final mimeType = lookupMimeType(filename) ?? 'application/octet-stream';

      await retry(
        () => _client.storage
            .from(bucketName)
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(contentType: mimeType, upsert: true),
            ),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
        onRetry: (e) => debugPrint('Retrying web upload: $e'),
      );

      final publicUrl = _client.storage.from(bucketName).getPublicUrl(fileName);

      return UploadResult(fileURL: publicUrl, filePath: fileName);
    } catch (e, stack) {
      debugPrint('Web Upload Exception: $e');
      debugPrint('StackTrace: $stack');
      throw Exception('Supabase web upload failed: $e');
    }
  }

  Future<void> deleteFile(String filePath) async {
    try {
      await _client.storage.from(bucketName).remove([filePath]);
      debugPrint("🗑️ Deleted file from Supabase: $filePath");
    } catch (e, stackTrace) {
      debugPrint("⚠️ Error deleting file: $e");
      debugPrint("StackTrace: $stackTrace");
      throw Exception('File deletion failed: $e');
    }
  }
}
