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
  final String _currentPeriod = '2026-10';

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  // Fungsi helper untuk memformat angka menjadi format Rupiah (contoh: Rp 500.000)
  String _formatRupiah(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Future<void> _loadBudgets() async {
    setState(() { _isLoading = true; });

    try {
      final budgets = await DatabaseHelper.instance.getBudgetsByPeriod(_currentPeriod);
      
      Map<int, double> spentData = {};
      for (var budget in budgets) {
        int categoryId = budget['category_id'];
        double spent = await DatabaseHelper.instance.getTotalSpentByCategoryAndPeriod(categoryId, _currentPeriod);
        spentData[categoryId] = spent;
      }

      setState(() {
        _budgetList = budgets;
        _spentMap = spentData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data anggaran: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batas Anggaran Bulanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBudgets,
            tooltip: 'Muat Ulang Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _budgetList.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada batas anggaran diatur.\nTekan tombol + di bawah untuk menambah.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
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
                    
                    double progress = monthlyLimit > 0 ? (spent / monthlyLimit) : 0.0;
                    if (progress > 1.0) progress = 1.0;

                    bool isOver80 = (spent / monthlyLimit) >= 0.8;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Waspada 80%+',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Terpakai: ${_formatRupiah(spent)}', style: const TextStyle(color: Colors.black87)),
                                Text('Batas: ${_formatRupiah(monthlyLimit)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[200],
                                color: isOver80 ? Colors.red : Colors.green,
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
          );
          if (result == true) {
            _loadBudgets();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Atur Anggaran'),
      ),
    );
  }
}