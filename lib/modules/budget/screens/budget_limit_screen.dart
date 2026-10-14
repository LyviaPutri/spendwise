import 'package:flutter/material.dart';
import 'package:spendwise/core/database/database_helper.dart';
import 'package:spendwise/modules/budget/screens/add_budget_screen.dart';

class BudgetLimitScreen extends StatefulWidget {
  const BudgetLimitScreen({super.key});

  @override
  State<BudgetLimitScreen> createState() => _BudgetLimitScreenState();
}

class _BudgetLimitScreenState extends State<BudgetLimitScreen> {
  List<Map<String, dynamic>> _budgetList = [];
  Map<int, double> _spentMap = {};
  bool _isLoading = true;
  final String _currentPeriod = '2026-10'; // Periode aktif sesuai PRD

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  // Fungsi untuk memuat data pagu anggaran dan realisasi belanja dari SQLite (Read - FR-16)
  Future<void> _loadBudgets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Ambil daftar anggaran berdasarkan periode dari database_helper
      final budgets = await DatabaseHelper.instance.getBudgetsByPeriod(_currentPeriod);
      
      Map<int, double> spentData = {};
      for (var budget in budgets) {
        int categoryId = budget['category_id'];
        // 2. Kontrak Titik Temu: Hitung realisasi belanja dari tabel expenses milik Febi
        double spent = await DatabaseHelper.instance.getTotalSpentByCategoryAndPeriod(categoryId, _currentPeriod);
        spentData[categoryId] = spent;
      }

      setState(() {
        _budgetList = budgets;
        _spentMap = spentData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data anggaran: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batas Anggaran Bulanan (Modul 3)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBudgets,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _budgetList.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada pagu anggaran diatur.\nTekan tombol + di bawah untuk menambah.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _budgetList.length,
                  itemBuilder: (context, index) {
                    final budget = _budgetList[index];
                    final categoryName = budget['category_name'] ?? 'Kategori';
                    final monthlyLimit = (budget['monthly_limit'] as num).toDouble();
                    final categoryId = budget['category_id'];
                    final spent = _spentMap[categoryId] ?? 0.0;
                    
                    // Kalkulasi persentase penyerapan anggaran untuk Progress Bar
                    double progress = monthlyLimit > 0 ? (spent / monthlyLimit) : 0.0;
                    if (progress > 1.0) progress = 1.0; // Batasi maksimal 100%

                    // Cek kondisi overspending >= 80% (FR-21)
                    bool isOver80 = (spent / monthlyLimit) >= 0.8;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  categoryName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (isOver80)
                                  const Chip(
                                    label: Text('Waspada 80%+', style: TextStyle(color: Colors.white, fontSize: 11)),
                                    backgroundColor: Colors.red,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Terpakai: Rp ${spent.toStringAsFixed(0)}'),
                                Text('Pagu: Rp ${monthlyLimit.toStringAsFixed(0)}'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Indikator Visual Progres Penyerapan Anggaran (Budget Progress Bar)
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[200],
                              color: isOver80 ? Colors.red : Colors.green,
                              minHeight: 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      // Tombol untuk navigasi ke form input anggaran (Create - FR-15)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigasi ke AddBudgetScreen dan menunggu hasil kembali (result)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
          );
          
          // Jika berhasil menyimpan, muat ulang daftar anggaran
          if (result == true) {
            _loadBudgets();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}