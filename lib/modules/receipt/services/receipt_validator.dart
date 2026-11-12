import 'dart:io';
import 'package:image_picker/image_picker.dart';

// Hasil penyaringan: daftar path valid + jumlah yang ditolak
class ValidationResult {
  final List<String> validPaths;
  final int rejected;
  ValidationResult(this.validPaths, this.rejected);
}

class ReceiptValidator {
  static const int maxSizeBytes = 5 * 1024 * 1024; // 5 MB

  static Future<ValidationResult> filterValid(List<XFile> files) async {
    final List<String> validPaths = [];
    int rejected = 0;
    for (final file in files) {
      final path = file.path.toLowerCase();
      final validFormat = path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png');
      final size = await File(file.path).length();
      if (validFormat && size <= maxSizeBytes) {
        validPaths.add(file.path);
      } else {
        rejected++;
      }
    }
    return ValidationResult(validPaths, rejected);
  }
}