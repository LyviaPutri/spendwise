import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_helper.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  var _recentExpenses = []; // Menggunakan var agar VS Code tidak error membaca tanda < >
  double _totalBulanIni = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBerandaData();
  }

  Future<void> _loadBerandaData() async {
    final data = await DatabaseHelper.instance.getExpenses();
    
    double total = 0;
    DateTime now = DateTime.now();

    for (var exp in data) {
      DateTime expDate = DateTime.parse(exp['expense_date']);
      if (expDate.year == now.year && expDate.month == now.month) {
        total += (exp['amount'] as num).toDouble();
      }
    }

    // Menggunakan spread operator [...data] untuk menghindari error "dot-shorthand"
    var sortedData = [...data];
    sortedData.sort((a, b) => DateTime.parse(b['expense_date']).compareTo(DateTime.parse(a['expense_date'])));
    final recent = sortedData.take(3).toList();

    setState(() {
      _totalBulanIni = total;
      _recentExpenses = recent;
      _isLoading = false;
    });
  }

  String _formatRupiah(double amount, {String symbol = 'Rp'}) {
    return NumberFormat.currency(locale: 'id', symbol: symbol, decimalDigits: 0).format(amount);
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'confirmation_number': return Icons.confirmation_number;
      default: return Icons.grid_view_rounded;
    }
  }

  Color _getColor(String? hexColor) {
    if (hexColor == null) return const Color(0xFF64748B);
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) hexColor = 'FF$hexColor';
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: const Column( // Diperbarui dengan const
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SpendWise', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text('Halo, Febiola!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDashboardCard(),
                const SizedBox(height: 16),
                _buildWarningCard(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Transaksi Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Lihat semua >', style: TextStyle(color: Color(0xFF2563EB))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRecentTransactions(),
              ],
            ),
          ),
    );
  }

  Widget _buildDashboardCard() {
    // TODO (Nasywa): Ambil target budget dari database Anggaran
    const double targetBudget = 2000000; // Diperbarui dengan const
    double remainingBudget = targetBudget - _totalBulanIni;
    double percentage = _totalBulanIni / targetBudget;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pengeluaran Bulan Ini', style: TextStyle(color: Colors.grey)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
                child: Text(DateFormat('MMM yyyy').format(DateTime.now()), style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_formatRupiah(_totalBulanIni), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Anggaran: ${_formatRupiah(targetBudget)}', style: const TextStyle(color: Colors.grey)),
              Text('Sisa ${_formatRupiah(remainingBudget)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage > 1 ? 1 : percentage, 
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(percentage * 100).toStringAsFixed(0)}% anggaran terpakai', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: percentage > 0.8 ? Colors.red.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.circle, color: percentage > 0.8 ? Colors.red : Colors.green, size: 8),
                    const SizedBox(width: 4),
                    Text(percentage > 0.8 ? 'Kritis' : 'Aman', style: TextStyle(color: percentage > 0.8 ? Colors.red : Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: const Row( // Diperbarui dengan const
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Catatan Tim', style: TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Fitur limit warning per kategori akan dikerjakan oleh Nasywa.', style: TextStyle(color: Color(0xFF92400E), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    if (_recentExpenses.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('Belum ada transaksi.')));
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentExpenses.length,
      itemBuilder: (context, index) {
        final expense = _recentExpenses[index];
        final catColor = _getColor(expense['color_hex']);
        final catIcon = _getIconData(expense['icon_name']);
        final timeStr = DateFormat('HH:mm').format(DateTime.parse(expense['expense_date']));

        return Card(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1), // Diperbarui ke withValues
                borderRadius: BorderRadius.circular(10)
              ),
              child: Icon(catIcon, color: catColor, size: 20),
            ),
            title: Text(expense['notes']?.isEmpty ?? true ? 'Pengeluaran' : expense['notes'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('${expense['category_name']} • $timeStr', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            trailing: Text('-${_formatRupiah((expense['amount'] as num).toDouble())}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        );
      },
    );
  }
}