import 'package:flutter/material.dart';

import '../models/catatan.dart';
import '../models/transaksi.dart';
import '../routes/app_routes.dart';
import '../utils/formatters.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Transaksi _transaksi;
  bool _sudahAmbilArgumen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Menerima data yang dikirim dari Home (cukup diambil sekali).
    if (!_sudahAmbilArgumen) {
      _transaksi = ModalRoute.of(context)!.settings.arguments as Transaksi;
      _sudahAmbilArgumen = true;
    }
  }

  Future<void> _tambahCatatan() async {
    // Buka form, lalu TUNGGU hasil yang dikirim balik lewat Navigator.pop.
    // Catatan: JANGAN pakai pushNamed<String>() dengan tabel `routes`,
    // karena route dibuat bertipe dynamic dan menyebabkan error cast.
    final hasil = await Navigator.pushNamed(
      context,
      AppRoutes.formCatatan,
      arguments: _transaksi.judul,
    );

    // Jika pengguna menekan back, hasil bernilai null -> abaikan.
    if (hasil is! String || !mounted) return;

    setState(() {
      _transaksi.catatan.add(Catatan(isi: hasil, waktu: DateTime.now()));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan berhasil ditambahkan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _transaksi;
    final warna = t.isPengeluaran ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.judul, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    '${t.isPengeluaran ? '-' : '+'}${Formatters.rupiah(t.jumlah)}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: warna, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 24),
                  _baris(Icons.category_outlined, 'Kategori', t.kategori),
                  _baris(Icons.calendar_today_outlined, 'Tanggal',
                      Formatters.tanggal(t.tanggal)),
                  _baris(
                    Icons.swap_vert,
                    'Jenis',
                    t.isPengeluaran ? 'Pengeluaran' : 'Pemasukan',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Catatan', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (t.catatan.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Belum ada catatan')),
            )
          else
            for (final c in t.catatan)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.sticky_note_2_outlined),
                  title: Text(c.isi),
                  subtitle: Text(Formatters.tanggalWaktu(c.waktu)),
                ),
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-detail',
        onPressed: _tambahCatatan,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Catatan'),
      ),
    );
  }

  Widget _baris(IconData icon, String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text('$label: '),
          Expanded(
            child: Text(
              nilai,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
