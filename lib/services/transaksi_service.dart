import '../data/dummy_data.dart';
import '../models/transaksi.dart';

/// ====== SAKLAR SIMULASI (ubah manual untuk menguji Home) ======
/// true  -> Home menampilkan tampilan ERROR + tombol "Coba Lagi"
bool _simulateError = true;

/// true  -> Home menampilkan tampilan KOSONG
bool _simulateEmpty = false;
/// ==============================================================

/// Service palsu: meniru pengambilan data dari server (ada delay).
class TransaksiService {
  static final List<Transaksi> _data =
      _simulateEmpty ? <Transaksi>[] : buatDataDummy();

  static void tambah(Transaksi t) => _data.insert(0, t);

  static int idBerikutnya() => _data.isEmpty
      ? 1
      : _data.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;

  static Future<List<Transaksi>> ambilTransaksi({
    bool tanpaDelay = false,
  }) async {
    if (!tanpaDelay) await Future.delayed(const Duration(seconds: 2));

    if (_simulateError) {
      throw Exception('Gagal terhubung ke server');
    }
    return _data;
  }
}
