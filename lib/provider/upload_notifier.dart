// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retail_demand/services/upload_service.dart';
import 'package:retry/retry.dart';

enum UploadState { idle, uploading, success, error }

class UploadNotifier extends StateNotifier<UploadState> {
  UploadNotifier(this._uploadService) : super(UploadState.idle);

  final UploadService _uploadService;
  String fileURL = "";
  String filePath = "";
  String errorMessage = "";

  /// ✅ For Mobile (File Upload)
  Future<void> uploadFile(File file) async {
    if (!file.existsSync()) {
      errorMessage = 'File does not exist: ${file.path}';
      state = UploadState.error;
      return;
    }

    if (file.lengthSync() > 50 * 1024 * 1024) {
      errorMessage = 'File too large (max 50MB)';
      state = UploadState.error;
      return;
    }

    state = UploadState.uploading;

    try {
      final result = await retry(
        () => _uploadService.uploadFile(file),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
        onRetry: (e) => print('Retrying upload: $e'),
      );

      fileURL = result.fileURL;
      filePath = result.filePath;
      state = UploadState.success;
    } catch (e) {
      errorMessage = e.toString();
      print('Upload error: $e');
      state = UploadState.error;
      rethrow;
    }
  }

  /// ✅ For Web (Bytes Upload)
  Future<void> uploadFileFromBytes(Uint8List bytes, String filename) async {
    state = UploadState.uploading;

    try {
      final result = await retry(
        () => _uploadService.uploadBytes(bytes, filename),
        maxAttempts: 3,
        delayFactor: const Duration(seconds: 1),
        onRetry: (e) => print('Retrying web upload: $e'),
      );

      fileURL = result.fileURL;
      filePath = result.filePath;
      state = UploadState.success;
    } catch (e) {
      errorMessage = e.toString();
      print('Web upload error: $e');
      state = UploadState.error;
      rethrow;
    }
  }

  Future<void> deleteUploadedFile() async {
    try {
      if (filePath.isNotEmpty) {
        await _uploadService.deleteFile(filePath);
        print("File deleted from Supabase: $filePath");
      }
    } catch (e) {
      print("Error deleting file: $e");
    }
  }
}

final uploadNotifierProvider =
    StateNotifierProvider<UploadNotifier, UploadState>(
      (ref) => UploadNotifier(UploadService()),
    );
