import '../models/transaksi.dart';

/// Akun dummy untuk login (belum ada backend).
/// Email: mahasiswa@spendwise.com  |  Password: 123456
const String dummyEmail = 'mahasiswa@spendwise.com';
const String dummyPassword = '123456';

/// Mengembalikan daftar transaksi dummy (list baru setiap dipanggil).
List<Transaksi> buatDataDummy() {
  return [
    Transaksi(
      id: 1,
      judul: 'Makan siang di kantin',
      kategori: 'Makanan',
      jumlah: 18000,
      tanggal: DateTime(2026, 9, 28),
    ),
    Transaksi(
      id: 2,
      judul: 'Ongkos ojek ke kampus',
      kategori: 'Transportasi',
      jumlah: 12000,
      tanggal: DateTime(2026, 9, 28),
    ),
    Transaksi(
      id: 3,
      judul: 'Beli buku Flutter',
      kategori: 'Pendidikan',
      jumlah: 85000,
      tanggal: DateTime(2026, 9, 26),
    ),
    Transaksi(
      id: 4,
      judul: 'Uang saku bulanan',
      kategori: 'Pemasukan',
      jumlah: 1500000,
      tanggal: DateTime(2026, 9, 25),
      isPengeluaran: false,
    ),
    Transaksi(
      id: 5,
      judul: 'Paket data internet',
      kategori: 'Tagihan',
      jumlah: 50000,
      tanggal: DateTime(2026, 9, 24),
    ),
  ];
}
