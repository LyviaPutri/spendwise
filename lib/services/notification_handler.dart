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

          if (pack == 'com.gojek.app' || pack == 'com.gojek.gopay') {
            
            // 1. PERBAIKAN REGEX NOMINAL: Menangkap angka berapa pun (besar/kecil) di belakang Rp
            RegExp nominalRegex = RegExp(r'Rp\s?([\d\.]+)');
            Match? nominalMatch = nominalRegex.firstMatch(text);

            if (nominalMatch != null) {
              _lastNotificationText = text;
              _lastNotificationTime = now;

              // Membersihkan titik pemisah ribuan agar bisa di-parse menjadi double
              String nominalString = nominalMatch.group(1)!.replaceAll('.', '');
              double amount = double.tryParse(nominalString) ?? 0.0;

              // 2. PERBAIKAN REGEX MERCHANT/PENERIMA
              String merchantName = "GoPay Merchant";
              
              // Skenario A: Untuk transaksi belanja / pembayaran (biasanya pakai "ke X sebesar")
              RegExp merchantRegexPay = RegExp(r'ke\s(.*?)\ssebesar');
              Match? matchPay = merchantRegexPay.firstMatch(text);
              
              // Skenario B: Untuk transfer antar teman (P2P) ("transfer RpX ke [Nama].")
              RegExp merchantRegexTransfer = RegExp(r'ke\s([^.]+)');
              Match? matchTransfer = merchantRegexTransfer.firstMatch(text);

              // Cek skenario A dulu, kalau gagal, pakai skenario B
              if (matchPay != null) {
                merchantName = matchPay.group(1)!.trim();
              } else if (matchTransfer != null) {
                merchantName = matchTransfer.group(1)!.trim();
                // Opsional: Hapus kata "Lyvia Putri Lestari" agar murni nama saja kalau ada sisa teks aneh
              }

              debugPrint("Nominal Extracted: $amount | Merchant/Penerima: $merchantName");

              // Menyimpan data
              final newExpense = ExpenseModel(
                categoryId: 5, // Lainnya
                amount: amount,
                expenseDate: DateTime.now().toIso8601String(),
                notes: 'Otomatis dari GoPay', 
                merchantName: merchantName, 
                paymentMethod: 'Non-Tunai', 
                source: 'gopay',
              );

              try {
                await DatabaseHelper.instance.insertExpense(newExpense);
                debugPrint("✅ Berhasil disimpan ke SQLite Lokal");
                
                bool isSynced = await ApiService.syncExpenseToServer(newExpense);
                if (isSynced) {
                  debugPrint("✅ Berhasil disinkronisasi ke XAMPP Server");
                } else {
                  debugPrint("❌ Gagal sinkronisasi ke XAMPP Server (Cek IP/Koneksi)");
                }
              } catch (e) {
                debugPrint("❌ Gagal memproses data notifikasi: $e");
              }
              
            } else {
               debugPrint("❌ Nominal tidak ditemukan dalam notifikasi Gojek ini.");
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