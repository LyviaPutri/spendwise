import 'catatan.dart';

/// Model satu transaksi pengeluaran / pemasukan.
class Transaksi {
  final int id;
  final String judul;
  final String kategori;
  final int jumlah; // dalam rupiah
  final DateTime tanggal;
  final bool isPengeluaran;
  final List<Catatan> catatan;

  Transaksi({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.jumlah,
    required this.tanggal,
    this.isPengeluaran = true,
    List<Catatan>? catatan,
  }) : catatan = catatan ?? [];
}
