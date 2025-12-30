import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

// This is a top-level function, required for use with compute.
String _encodeBase64(List<int> bytes) {
  return base64Encode(bytes);
}

class FileUtils {
  /// Validates the extension of a file.
  static bool validateExtension(String filePath, List<String> allowedExtensions) {
    final String extension = p.extension(filePath);
    if (extension.isEmpty || !extension.startsWith('.')) {
      return false; // No extension found
    }
    final String fileExtension = extension.substring(1).toLowerCase();
    return allowedExtensions.map((e) => e.toLowerCase()).contains(fileExtension);
  }

  /// Gets the size of a file in kilobytes.
  static Future<double> getFileSizeKB(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      final bytes = await file.length();
      return bytes / 1024.0;
    }
    return 0.0;
  }

  /// Validates the file size is within the given range (in KB).
  static Future<bool> validateFileSize(String filePath, num minSizeKB, num maxSizeKB) async {
    final sizeKB = await getFileSizeKB(filePath);
    return sizeKB >= minSizeKB && sizeKB <= maxSizeKB;
  }

  /// Converts a file to a Base64 encoded string using a background isolate.
  static Future<String?> fileToBase64(String? filePath) async {
    if (filePath == null) return null;
    final file = File(filePath);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      // Use compute to run the encoding on a background thread to prevent UI freezing.
      return compute(_encodeBase64, bytes);
    }
    return null;
  }
}
