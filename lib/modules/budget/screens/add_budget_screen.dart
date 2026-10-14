import 'package:flutter/material.dart';
import 'package:spendwise/core/database/database_helper.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _limitController = TextEditingController();
  
  int? _selectedCategoryId;
  final String _currentPeriod = '2026-10'; // Format YYYY-MM sesuai PRD
  bool _isLoading = false;

  // Daftar kategori dengan ikon agar UI lebih menarik
  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Makanan & Minuman', 'icon': Icons.fastfood},
    {'id': 2, 'name': 'Transportasi', 'icon': Icons.directions_car},
    {'id': 3, 'name': 'Belanja', 'icon': Icons.shopping_bag},
    {'id': 4, 'name': 'Tagihan & Hiburan', 'icon': Icons.receipt_long},
  ];

  Future<void> _saveBudget() async {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      setState(() { _isLoading = true; });

      try {
        await DatabaseHelper.instance.insertBudgetLimit({
          'category_id': _selectedCategoryId,
          'monthly_limit': double.parse(_limitController.text),
          'period_month_year': _currentPeriod,
          'alert_80_sent': 0,
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Batas anggaran bulanan berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true); 
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan anggaran: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() { _isLoading = false; });
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
        title: const Text('Atur Batas Anggaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dropdown Kategori dengan Ikon
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Kategori Belanja',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem<int>(
                    value: cat['id'],
                    child: Row(
                      children: [
                        Icon(cat['icon'], size: 20, color: Colors.blueGrey),
                        const SizedBox(width: 12),
                        Text(cat['name']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Input Nominal Batas Anggaran
              TextFormField(
                controller: _limitController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal Batas Bulanan (Rp)',
                  hintText: 'Contoh: 750000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nominal batas anggaran tidak boleh kosong!';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Masukkan angka nominal yang valid!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveBudget,
                icon: const Icon(Icons.save),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Batas Anggaran', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}