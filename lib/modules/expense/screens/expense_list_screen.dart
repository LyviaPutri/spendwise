import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_helper.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Map<String, dynamic>> _expenses = [];
  bool _isLoading = true;
  
  // Search Features
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter Categories
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Makanan', 'Transport', 'Belanja', 'Hiburan', 'Lainnya'];
  
  // Filter Time
  String _selectedTimeFilter = 'Semua';
  final List<String> _timeFilters = ['Semua', 'Hari ini', 'Minggu ini', 'Bulan ini'];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getExpenses();
    setState(() {
      _expenses = data;
      _isLoading = false;
    });
  }

  Future<void> _deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    _loadExpenses();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil dihapus')),
      );
    }
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

  Map<String, List<Map<String, dynamic>>> _groupExpensesByDate() {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    DateTime now = DateTime.now();

    for (var expense in _expenses) {
      // 1. Pengecekan Filter Pencarian (Live Search)
      if (_searchQuery.isNotEmpty) {
        final merchant = (expense['merchant_name'] ?? '').toLowerCase();
        final notes = (expense['notes'] ?? '').toLowerCase();
        final category = (expense['category_name'] ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        if (!merchant.contains(query) && !notes.contains(query) && !category.contains(query)) {
          continue; // Lewati jika tidak ada yang cocok dengan kata kunci
        }
      }

      // 2. Pengecekan Filter Kategori
      bool matchCategory = _selectedFilter == 'Semua' || expense['category_name'] == _selectedFilter;
      if (!matchCategory) continue; 

      // 3. Pengecekan Filter Waktu
      DateTime expenseDate = DateTime.parse(expense['expense_date']);
      bool matchTime = false;

      if (_selectedTimeFilter == 'Semua') {
        matchTime = true;
      } else if (_selectedTimeFilter == 'Hari ini') {
        matchTime = expenseDate.year == now.year &&
                    expenseDate.month == now.month &&
                    expenseDate.day == now.day;
      } else if (_selectedTimeFilter == 'Minggu ini') {
        int daysToSubtract = now.weekday - 1;
        DateTime startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract));
        DateTime endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        
        matchTime = expenseDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
                    expenseDate.isBefore(endOfWeek.add(const Duration(seconds: 1)));
      } else if (_selectedTimeFilter == 'Bulan ini') {
        matchTime = expenseDate.year == now.year && expenseDate.month == now.month;
      }

      if (!matchTime) continue; 

      final dateString = DateFormat('dd MMMM yyyy').format(expenseDate);
      if (!grouped.containsKey(dateString)) {
        grouped[dateString] = [];
      }
      grouped[dateString]!.add(expense);
    }
    
    return grouped;
  }

  String _formatRupiah(double amount, {String symbol = 'Rp'}) {
    String formatted = NumberFormat.currency(locale: 'id', symbol: symbol, decimalDigits: 2).format(amount);
    if (formatted.endsWith(',00')) {
      formatted = formatted.substring(0, formatted.length - 3);
    }
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final groupedExpenses = _groupExpensesByDate();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Cari catatan atau toko...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
              ),
              style: const TextStyle(color: Color(0xFF0F172A), fontFamily: 'Inter', fontSize: 16),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            )
          : const Text(
              'Riwayat Pengeluaran',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search, color: const Color(0xFF0F172A)),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.filter_list, color: Color(0xFF0F172A)),
              onPressed: () {},
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _timeFilters.map((filter) {
                final isSelected = filter == _selectedTimeFilter;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedTimeFilter = filter);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = filter == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : groupedExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long_rounded, size: 48, color: Color(0xFFE2E8F0)),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty 
                                ? 'Tidak ada transaksi dengan kata kunci "$_searchQuery"'
                                : 'Belum ada transaksi di periode/kategori ini', 
                              style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF64748B), fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: groupedExpenses.length,
                        itemBuilder: (context, index) {
                          String dateKey = groupedExpenses.keys.elementAt(index);
                          List<Map<String, dynamic>> dayExpenses = groupedExpenses[dateKey]!;

                          double totalDay = dayExpenses.fold(0, (sum, item) => sum + item['amount']);
                          String totalDayStr = _formatRupiah(totalDay, symbol: 'Rp');

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dateKey,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                    Text(
                                      totalDayStr,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...dayExpenses.map((expense) {
                               final amountStr = _formatRupiah((expense['amount'] as num).toDouble(), symbol: '-Rp');
                                final date = DateTime.parse(expense['expense_date']);
                                final timeStr = DateFormat('HH:mm').format(date);
                                final catColor = _getColor(expense['color_hex']);
                                final catIcon = _getIconData(expense['icon_name']);
                                final expenseId = expense['id']; 

                                return Dismissible(
                                  key: Key(expenseId.toString()),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (direction) async {
                                    return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                            'Hapus Transaksi?',
                                            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
                                          ),
                                          content: const Text(
                                            'Tindakan ini tidak dapat dibatalkan.',
                                            style: TextStyle(fontFamily: 'Inter'),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text(
                                                'Batal',
                                                style: TextStyle(color: Color(0xFF64748B), fontFamily: 'Inter', fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: const Text(
                                                'Hapus',
                                                style: TextStyle(color: Color(0xFFEF4444), fontFamily: 'Inter', fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20.0),
                                    margin: const EdgeInsets.only(bottom: 16.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                                  ),
                                  onDismissed: (direction) {
                                    _deleteExpense(expenseId);
                                  },
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddExpenseScreen(
                                            expenseId: expenseId,
                                            initialAmount: expense['amount']?.toDouble(),
                                            initialCategoryId: expense['category_id'],
                                            initialNotes: expense['notes'],
                                            initialPaymentMethod: expense['payment_method'],
                                            initialDate: DateTime.parse(expense['expense_date']),
                                          ),
                                        ),
                                      );
                                      _loadExpenses();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 16.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: catColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(catIcon, color: catColor, size: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        expense['notes']?.isEmpty ?? true ? 'Pengeluaran' : expense['notes'],
                                                        style: const TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 14,
                                                          color: Color(0xFF0F172A),
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFF1F5F9),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        expense['payment_method'] ?? 'Tunai', 
                                                        style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontFamily: 'Inter'),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Text(
                                                      expense['category_name'],
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 12,
                                                        color: catColor,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      timeStr,
                                                      style: const TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 12,
                                                        color: Color(0xFF94A3B8),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            amountStr,
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const Divider(color: Color(0xFFF1F5F9)),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
          _loadExpenses(); 
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}