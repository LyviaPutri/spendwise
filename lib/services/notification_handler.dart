import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../core/database/database_helper.dart';
import '../models/expense_model.dart';
import 'api_service.dart';

class NotificationHandler {
  static const MethodChannel _channel = MethodChannel('spendwise/notifikasi');
  
  // Variabel untuk menyimpan histori notifikasi terakhir (Anti-Duplikat)
  static String _lastNotificationText = "";
  static DateTime? _lastNotificationTime;

  static void startListening() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "notifikasiMasuk") {
        String info = call.arguments.toString();
        
        List<String> lines = info.split('\n');
        if (lines.length >= 3) {
          String pack = lines[0].replaceFirst('Dari: ', '').trim();
          String title = lines[1].replaceFirst('Judul: ', '').trim();
          String text = lines[2].replaceFirst('Isi: ', '').trim();

          // Pengecekan Anti-Duplikat (Mencegah input ganda dalam jeda 5 detik)
          DateTime now = DateTime.now();
          if (text == _lastNotificationText && _lastNotificationTime != null) {
            if (now.difference(_lastNotificationTime!).inSeconds < 5) {
              debugPrint("Mencegah duplikat: Notifikasi yang sama baru saja diproses.");
              return; // Hentikan eksekusi di sini agar tidak tersimpan ganda
            }
          }

          // Pastikan mengganti ke 'com.gojek.app' saat nanti dirilis
          if (pack == 'com.gojek.app' || pack == 'com.gojek.gopay') {
            
            RegExp nominalRegex = RegExp(r'Rp\s?([\d\.]+)');
            Match? nominalMatch = nominalRegex.firstMatch(text);

            if (nominalMatch != null) {
              // Jika valid, perbarui rekam jejak notifikasi terakhir
              _lastNotificationText = text;
              _lastNotificationTime = now;

              String nominalString = nominalMatch.group(1)!.replaceAll('.', '');
              double amount = double.tryParse(nominalString) ?? 0.0;

              String merchantName = "GoPay Merchant";
              RegExp merchantRegex = RegExp(r'ke\s(.*?)\ssebesar');
              Match? merchantMatch = merchantRegex.firstMatch(text);
              if (merchantMatch != null) {
                merchantName = merchantMatch.group(1)!.trim();
              }

              debugPrint("Nominal Extracted: $amount | Merchant: $merchantName");

              // Menyimpan data
              final newExpense = ExpenseModel(
                categoryId: 5, // Lainnya
                amount: amount,
                expenseDate: DateTime.now().toIso8601String(),
                notes: 'Otomatis dari GoPay', // Digeser menjadi catatan
                merchantName: merchantName, // Nama merchant (Kantin Kampus) jadi judul utama
                paymentMethod: 'Non-Tunai', // Disamakan dengan standar manual
                source: 'gopay',
              );

              try {
                await DatabaseHelper.instance.insertExpense(newExpense);
                debugPrint("✅ Berhasil disimpan ke SQLite Lokal");
                
                bool isSynced = await ApiService.syncExpenseToServer(newExpense);
                if (isSynced) {
                  debugPrint("✅ Berhasil disinkronisasi ke XAMPP Server");
                } else {
                  debugPrint("❌ Gagal sinkronisasi ke XAMPP Server");
                }
              } catch (e) {
                debugPrint("❌ Gagal memproses data notifikasi: $e");
              }
              
            }
          }
        }
      }
    });
  }

  static Future<bool> checkPermission() async {
    final bool isGranted = await _channel.invokeMethod('cekIzin');
    return isGranted;
  }

  static Future<void> openSettings() async {
    await _channel.invokeMethod('bukaPengaturan');
  }
}