import 'package:flutter/material.dart';

class CatatanFormScreen extends StatelessWidget {
  const CatatanFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi Baru')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Simpan & Kembali'),
        ),
      ),
    );
  }
}