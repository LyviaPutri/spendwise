import 'package:spendwise/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database_helper.dart';
import '../../../models/category_model.dart';
import '../../../models/expense_model.dart';

class AddExpenseScreen extends StatefulWidget {
  final int? expenseId; // Kunci penanda Mode Edit
  final double? initialAmount;
  final String? initialMerchant;
  final String? initialNotes;
  final String? initialPaymentMethod;
  final int? initialCategoryId;
  final DateTime? initialDate;
  final String? receiptImagePath;
  final String initialSource;

  const AddExpenseScreen({
    super.key,
    this.expenseId,
    this.initialAmount,
    this.initialMerchant,
    this.initialNotes,
    this.initialPaymentMethod,
    this.initialCategoryId,
    this.initialDate,
    this.receiptImagePath,
    this.initialSource = 'manual',
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  
  DateTime _selectedDate = DateTime.now();
  int _selectedCategoryId = 1; 

  String _selectedPaymentMethod = 'Tunai';
  final List<String> _paymentMethods = ['Tunai', 'Non-Tunai']; 

  List<CategoryModel> _dbCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount != null && widget.initialAmount! > 0
          ? widget.initialAmount!.toInt().toString()
          : '',
    );
    
    _notesController = TextEditingController(
      text: widget.initialNotes ?? widget.initialMerchant ?? '',
    );

    // Ambil data lama jika masuk dari Mode Edit
    if (widget.initialDate != null) _selectedDate = widget.initialDate!;
    if (widget.initialPaymentMethod != null) _selectedPaymentMethod = widget.initialPaymentMethod!;
    if (widget.initialCategoryId != null) _selectedCategoryId = widget.initialCategoryId!;
    
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await DatabaseHelper.instance.getCategories();
    setState(() {
      _dbCategories = categories;
      if (_dbCategories.isNotEmpty) {
        // Jangan timpa kategori jika sedang dalam Mode Edit
        if (widget.initialCategoryId == null) {
          _selectedCategoryId = _dbCategories.first.id!;
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _saveExpense() async {
    if (_amountController.text.isEmpty || _amountController.text == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal pengeluaran harus diisi!')),
      );
      return;
    }

    String rawAmount = _amountController.text.replaceAll('.', '');

    // JIKA MODE EDIT
    if (widget.expenseId != null) {
      await DatabaseHelper.instance.updateExpenseRaw(
        widget.expenseId!,
        {
          'category_id': _selectedCategoryId,
          'amount': double.tryParse(rawAmount) ?? 0.0,
          'expense_date': _selectedDate.toIso8601String(),
          'merchant_name': "", 
          'payment_method': _selectedPaymentMethod,
          'notes': _notesController.text.isEmpty ? null : _notesController.text,
          'source': widget.initialSource,
        }
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yeay! Perubahan berhasil disimpan 🎉')),
        );
      }
    } 
    // JIKA MODE TAMBAH BARU
    else {
      final expense = ExpenseModel(
        categoryId: _selectedCategoryId,
        amount: double.tryParse(rawAmount) ?? 0.0,
        expenseDate: _selectedDate.toIso8601String(), // Pastikan ini tetap toIso8601String() di sini
        merchantName: "", 
        paymentMethod: _selectedPaymentMethod,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        source: widget.initialSource,
      );
      
      // 1. Simpan ke SQLite lokal terlebih dahulu
      final insertedId = await DatabaseHelper.instance.insertExpense(expense);
      
      // 2. Jika sukses tersimpan di HP, kirim salinan datanya ke Server MySQL XAMPP
      if (insertedId > 0) {
        ApiService.syncExpenseToServer(expense);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yeay! Pengeluaran berhasil dicatat 🎉')),
        );
      }
    }

    if (mounted) Navigator.pop(context);
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'confirmation_number': return Icons.confirmation_number;
      default: return Icons.grid_view_rounded;
    }
  }

  Color _getColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB), 
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Penyesuaian Teks Dinamis
    final isEditMode = widget.expenseId != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          isEditMode ? 'Edit Pengeluaran' : 'Tambah Pengeluaran',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.receiptImagePath != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, color: Color(0xFF2563EB), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mengisi data berdasarkan struk kamera',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'NOMINAL',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: Row(
                children: [
                  const Text(
                    'Rp ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number, 
                      inputFormatters: [RupiahInputFormatter()],
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'KATEGORI',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 84,
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _dbCategories.length,
                itemBuilder: (context, index) {
                  final cat = _dbCategories[index];
                  final isSelected = _selectedCategoryId == cat.id;
                  
                  final catColor = _getColor(cat.colorHex);
                  final catIcon = _getIconData(cat.iconName);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = cat.id!;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? catColor.withValues(alpha: 0.12)
                                  : const Color(0xFFF8FAFC),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected 
                                    ? catColor 
                                    : const Color(0xFFE2E8F0),
                                width: isSelected ? 2.5 : 1.5,
                              ),
                            ),
                            child: Icon(
                              catIcon,
                              color: isSelected ? catColor : const Color(0xFF64748B),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 11,
                              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'METODE PEMBAYARAN',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: _paymentMethods.map((method) {
                final isSelected = _selectedPaymentMethod == method;
                return ChoiceChip(
                  label: Text(
                    method,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2563EB),
                  backgroundColor: const Color(0xFFF8FAFC),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedPaymentMethod = method;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            const Text(
              'Tanggal',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Icon(Icons.calendar_today_rounded, color: Color(0xFF64748B), size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Keterangan (opsional)', 
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLength: 50,
              controller: _notesController,
              maxLines: 2, 
              style: const TextStyle(fontSize: 14, fontFamily: 'Inter', color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'cth: Kopi Kenangan, atau bayar parkir...', 
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isEditMode ? 'Simpan Perubahan' : 'Simpan Pengeluaran',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            // Tombol Scan Struk kita sembunyikan saat Edit Mode, karena tidak masuk akal edit pakai scan
            if (!isEditMode) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF2563EB), size: 18),
                  label: const Text(
                    'Scan Struk',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return newValue.copyWith(text: '');
    
    int? parsed = int.tryParse(cleanText);
    if (parsed == null) return oldValue;
    
    String result = parsed.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.'
    );

    return newValue.copyWith(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}