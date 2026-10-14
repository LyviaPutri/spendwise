import 'package:flutter/material.dart';
import 'package:spendwise/core/database/database_helper.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  // GlobalKey digunakan untuk mengidentifikasi form dan memicu validasi
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk mengambil teks input nominal dari user
  final TextEditingController _limitController = TextEditingController();
  
  // Variabel state untuk menyimpan pilihan kategori dan periode
  int? _selectedCategoryId;
  final String _currentPeriod = '2026-10'; // Format baku 'YYYY-MM' sesuai PRD
  
  bool _isLoading = false;

  // Fungsi untuk menyimpan data ke database SQLite (Feedback & Proses)
  Future<void> _saveBudget() async {
    // 3. VALIDASI: Mengecek apakah form sudah memenuhi syarat
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Menyimpan data ke tabel budget_limits via DatabaseHelper
        await DatabaseHelper.instance.insertBudgetLimit({
          'category_id': _selectedCategoryId,
          'monthly_limit': double.parse(_limitController.text),
          'period_month_year': _currentPeriod,
          'alert_80_sent': 0,
        });

        if (!mounted) return;

        // 4. FEEDBACK: Menampilkan pesan sukses ke user berupa SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Batas anggaran bulanan berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );

        // 5. NAVIGATION: Kembali ke layar sebelumnya dan mengirimkan hasil true
        Navigator.pop(context, true); 
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan anggaran: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori belanja terlebih dahulu!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atur Pagu Anggaran Modul 3'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // 1. INPUT / EVENT: Form tempat user memilih kategori dan memasukkan nominal
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dropdown Pilihan Kategori (Master data dari SQLite)
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Kategori Belanja',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Makanan & Minuman')),
                  DropdownMenuItem(value: 2, child: Text('Transportasi')),
                  DropdownMenuItem(value: 3, child: Text('Belanja')),
                  DropdownMenuItem(value: 4, child: Text('Tagihan & Hiburan')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value; // 2. STATE: Memperbarui state pilihan kategori
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Input Teks Nominal Pagu Anggaran
              TextFormField(
                controller: _limitController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal Pagu Bulanan (Rp)',
                  hintText: 'Contoh: 750000',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  // 3. VALIDASI: Memastikan input tidak kosong dan berupa angka valid > 0
                  if (value == null || value.isEmpty) {
                    return 'Nominal pagu tidak boleh kosong!';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Masukkan angka nominal yang valid!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Tombol Eksekusi Aksi
              ElevatedButton(
                onPressed: _isLoading ? null : _saveBudget,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Pagu Anggaran'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}