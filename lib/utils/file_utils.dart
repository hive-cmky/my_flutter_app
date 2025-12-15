import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

class FileUtils {
  /// Validates the extension of a file.
  static bool validateExtension(String filePath, List<String> allowedExtensions) {
    final String extension = p.extension(filePath);
    if (extension.isEmpty || !extension.startsWith('.')) {
      return false; // No extension found
    }
    // Get extension without the dot and convert to lower case
    final String fileExtension = extension.substring(1).toLowerCase();
    
    // Check if the extension is in the allowed list
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

  /// Converts a file to a Base64 encoded string.
  static Future<String?> fileToBase64(String? filePath) async {
    if (filePath == null) return null;
    final file = File(filePath);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    }
    return null;
  }
}
