import 'package:flutter/material.dart';

import '../utils/validators.dart';

class FormCatatanScreen extends StatefulWidget {
  const FormCatatanScreen({super.key});

  @override
  State<FormCatatanScreen> createState() => _FormCatatanScreenState();
}

class _FormCatatanScreenState extends State<FormCatatanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    // Kirim teks catatan kembali ke Detail lewat pop.
    Navigator.pop(context, _catatanController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    // Judul transaksi dikirim dari Detail sebagai argumen.
    final judulTransaksi = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Catatan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Untuk: $judulTransaksi',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _catatanController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: Validators.catatan,
              ),
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
