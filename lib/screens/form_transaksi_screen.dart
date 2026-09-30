import 'package:flutter/material.dart';

import '../models/transaksi.dart';
import '../services/transaksi_service.dart';
import '../utils/validators.dart';

class FormTransaksiScreen extends StatefulWidget {
  const FormTransaksiScreen({super.key});

  @override
  State<FormTransaksiScreen> createState() => _FormTransaksiScreenState();
}

class _FormTransaksiScreenState extends State<FormTransaksiScreen> {
  static const _kategori = [
    'Makanan',
    'Transportasi',
    'Pendidikan',
    'Tagihan',
    'Hiburan',
    'Lainnya',
  ];

  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _nominalController = TextEditingController();
  String _kategoriDipilih = _kategori.first;
  bool _isPengeluaran = true;

  @override
  void dispose() {
    _judulController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final transaksi = Transaksi(
      id: TransaksiService.idBerikutnya(),
      judul: _judulController.text.trim(),
      kategori: _isPengeluaran ? _kategoriDipilih : 'Pemasukan',
      jumlah: int.parse(_nominalController.text.trim()),
      tanggal: DateTime.now(),
      isPengeluaran: _isPengeluaran,
    );

    // Kirim transaksi baru kembali ke Home.
    Navigator.pop(context, transaksi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Pengeluaran')),
                  ButtonSegment(value: false, label: Text('Pemasukan')),
                ],
                selected: {_isPengeluaran},
                onSelectionChanged: (s) =>
                    setState(() => _isPengeluaran = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.judul,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal (Rp)',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.nominal,
              ),
              if (_isPengeluaran) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _kategoriDipilih,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final k in _kategori)
                      DropdownMenuItem(value: k, child: Text(k)),
                  ],
                  onChanged: (v) => setState(() => _kategoriDipilih = v!),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _simpan,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
