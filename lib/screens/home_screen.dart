import 'package:flutter/material.dart';

import '../models/transaksi.dart';
import '../routes/app_routes.dart';
import '../services/transaksi_service.dart';
import '../utils/formatters.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Transaksi>> _futureTransaksi;

  @override
  void initState() {
    super.initState();
    _futureTransaksi = TransaksiService.ambilTransaksi();
  }

  void _muatUlang() {
    setState(() {
      _futureTransaksi = TransaksiService.ambilTransaksi();
    });
  }

  Future<void> _tambahTransaksi() async {
    final hasil = await Navigator.pushNamed(context, AppRoutes.formTransaksi);
    if (hasil is! Transaksi || !mounted) return;

    TransaksiService.tambah(hasil);
    setState(() {
      _futureTransaksi = TransaksiService.ambilTransaksi(tanpaDelay: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendWise'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-home',
        onPressed: _tambahTransaksi,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Transaksi'),
      ),
      body: FutureBuilder<List<Transaksi>>(
        future: _futureTransaksi,
        builder: (context, snapshot) {
          // 1. LOADING
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat transaksi...'),
                ],
              ),
            );
          }

          // 2. ERROR
          if (snapshot.hasError) {
            return _PesanState(
              icon: Icons.error_outline,
              warna: Theme.of(context).colorScheme.error,
              judul: 'Terjadi kesalahan',
              pesan: 'Data gagal dimuat. Periksa koneksi lalu coba lagi.',
              tombol: FilledButton.icon(
                onPressed: _muatUlang,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            );
          }

          final daftar = snapshot.data ?? [];

          // 3. EMPTY
          if (daftar.isEmpty) {
            return const _PesanState(
              icon: Icons.receipt_long_outlined,
              warna: Colors.grey,
              judul: 'Belum ada transaksi',
              pesan: 'Transaksi yang kamu catat akan muncul di sini.',
            );
          }

          // 4. DATA
          final totalPengeluaran = daftar
              .where((t) => t.isPengeluaran)
              .fold<int>(0, (sum, t) => sum + t.jumlah);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total pengeluaran'),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.rupiah(totalPengeluaran),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              for (final t in daftar) _ItemTransaksi(transaksi: t),
            ],
          );
        },
      ),
    );
  }
}

class _ItemTransaksi extends StatelessWidget {
  final Transaksi transaksi;

  const _ItemTransaksi({required this.transaksi});

  @override
  Widget build(BuildContext context) {
    final warna = transaksi.isPengeluaran ? Colors.red : Colors.green;
    final tanda = transaksi.isPengeluaran ? '-' : '+';

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: warna.withValues(alpha: 0.15),
          child: Icon(
            transaksi.isPengeluaran ? Icons.arrow_upward : Icons.arrow_downward,
            color: warna,
          ),
        ),
        title: Text(transaksi.judul),
        subtitle: Text(
          '${transaksi.kategori} • ${Formatters.tanggal(transaksi.tanggal)}',
        ),
        trailing: Text(
          '$tanda${Formatters.rupiah(transaksi.jumlah)}',
          style: TextStyle(color: warna, fontWeight: FontWeight.bold),
        ),
        // Kirim objek Transaksi ke halaman Detail lewat arguments.
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.detail,
          arguments: transaksi,
        ),
      ),
    );
  }
}

class _PesanState extends StatelessWidget {
  final IconData icon;
  final Color warna;
  final String judul;
  final String pesan;
  final Widget? tombol;

  const _PesanState({
    required this.icon,
    required this.warna,
    required this.judul,
    required this.pesan,
    this.tombol,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: warna),
            const SizedBox(height: 16),
            Text(judul, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(pesan, textAlign: TextAlign.center),
            if (tombol != null) ...[
              const SizedBox(height: 24),
              tombol!,
            ],
          ],
        ),
      ),
    );
  }
}
