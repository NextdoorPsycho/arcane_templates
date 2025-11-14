import 'dart:io';

import 'package:APPNAME_server/main.dart';
import 'package:fast_log/fast_log.dart';
import 'package:google_cloud/google_cloud.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

/// Service for managing media files (images, videos, etc.)
class MediaService {
  final _uuid = const Uuid();
  late final GoogleCloudStorage _storage;

  MediaService() {
    _storage = GoogleCloudStorage(bucket: bucket);
    verbose("MediaService initialized with bucket: $bucket");
  }

  /// Upload a file to Cloud Storage
  Future<String> uploadFile({
    required File file,
    required String userId,
    String? customName,
  }) async {
    try {
      final fileName = customName ?? _uuid.v4();
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final extension = mimeType.split('/').last;
      final fullName = '$fileName.$extension';
      final path = 'users/$userId/media/$fullName';

      verbose("Uploading file to $path");

      final bytes = await file.readAsBytes();

      await _storage.uploadBytes(
        path,
        bytes,
        metadata: {
          'contentType': mimeType,
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      verbose("File uploaded successfully: $path");

      return path;
    } catch (e) {
      error("Failed to upload file: $e");
      rethrow;
    }
  }

  /// Upload bytes directly
  Future<String> uploadBytes({
    required List<int> bytes,
    required String userId,
    required String fileName,
    String? mimeType,
  }) async {
    try {
      final path = 'users/$userId/media/$fileName';

      verbose("Uploading bytes to $path");

      await _storage.uploadBytes(
        path,
        bytes,
        metadata: {
          'contentType': mimeType ?? 'application/octet-stream',
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      verbose("Bytes uploaded successfully: $path");

      return path;
    } catch (e) {
      error("Failed to upload bytes: $e");
      rethrow;
    }
  }

  /// Get download URL for a file
  Future<String> getDownloadUrl(String path) async {
    try {
      return await _storage.getDownloadUrl(path);
    } catch (e) {
      error("Failed to get download URL for $path: $e");
      rethrow;
    }
  }

  /// Delete a file
  Future<void> deleteFile(String path) async {
    try {
      await _storage.delete(path);
      verbose("Deleted file: $path");
    } catch (e) {
      error("Failed to delete file $path: $e");
      rethrow;
    }
  }

  /// List files in a user's media folder
  Future<List<String>> listUserFiles(String userId) async {
    try {
      final prefix = 'users/$userId/media/';
      final files = await _storage.list(prefix: prefix);
      return files;
    } catch (e) {
      error("Failed to list files for user $userId: $e");
      return [];
    }
  }

  /// Get file metadata
  Future<Map<String, dynamic>?> getFileMetadata(String path) async {
    try {
      return await _storage.getMetadata(path);
    } catch (e) {
      error("Failed to get metadata for $path: $e");
      return null;
    }
  }
}
