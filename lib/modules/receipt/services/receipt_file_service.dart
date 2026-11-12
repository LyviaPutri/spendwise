import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ReceiptFileService {
  // Salin foto dari lokasi sementara (cache) ke folder dokumen aplikasi.
  // Mengembalikan path baru yang aman dan tidak akan dibersihkan sistem.
  static Future<String> copyToAppDir(String sourcePath) async {
    // 1. Minta alamat folder dokumen milik aplikasi
    final docsDir = await getApplicationDocumentsDirectory();

    // 2. Siapkan subfolder "receipts", buat kalau belum ada
    final receiptsDir = Directory(p.join(docsDir.path, 'receipts'));
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }

    // 3. Nama file unik (pakai waktu) + ekstensi asli (.jpg/.png)
    final ext = p.extension(sourcePath);
    final fileName = 'receipt_${DateTime.now().microsecondsSinceEpoch}$ext';
    final newPath = p.join(receiptsDir.path, fileName);

    // 4. Salin file, lalu kembalikan alamat barunya
    await File(sourcePath).copy(newPath);
    return newPath;
  }
}