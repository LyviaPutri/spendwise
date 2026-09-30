/// Model data transaksi pengeluaran aplikasi SpendWise.
/// Disesuaikan agar atributnya tetap cocok dengan modul latihan praktikum.
class Item {
  final String id;
  final String title; // Nama Merchant / Judul Pengeluaran
  final String subtitle; // Kategori & Nominal (contoh: "Makanan • Rp 25.000")
  final String description; // Catatan & Detail Transaksi

  const Item({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}