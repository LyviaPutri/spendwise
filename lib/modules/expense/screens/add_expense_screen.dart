import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  final double? initialAmount;
  final String? initialMerchant;
  final String? receiptImagePath;
  final String initialSource;

  const AddExpenseScreen({
    super.key,
    this.initialAmount,
    this.initialMerchant,
    this.receiptImagePath,
    this.initialSource = 'manual',
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late TextEditingController _amountController;
  late TextEditingController _merchantController;
  late TextEditingController _notesController;
  
  DateTime _selectedDate = DateTime.now();
  int _selectedCategoryId = 1; 

  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Makanan', 'icon': Icons.restaurant, 'color': const Color(0xFFF59E0B)},
    {'id': 2, 'name': 'Transport', 'icon': Icons.directions_car, 'color': const Color(0xFF2196F3)},
    {'id': 3, 'name': 'Belanja', 'icon': Icons.shopping_bag, 'color': const Color(0xFF4CAF50)},
    {'id': 4, 'name': 'Hiburan', 'icon': Icons.confirmation_number, 'color': const Color(0xFF9C27B0)},
    {'id': 5, 'name': 'Lainnya', 'icon': Icons.grid_view_rounded, 'color': const Color(0xFF64748B)},
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount != null && widget.initialAmount! > 0
          ? widget.initialAmount!.toInt().toString()
          : '',
    );
    _merchantController = TextEditingController(
      text: widget.initialMerchant ?? '',
    );
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Tambah Pengeluaran',
          style: TextStyle(
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
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategoryId == cat['id'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = cat['id'] as int;
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
                                  ? (cat['color'] as Color).withValues(alpha: 0.12)
                                  : const Color(0xFFF8FAFC),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected 
                                    ? cat['color'] as Color 
                                    : const Color(0xFFE2E8F0),
                                width: isSelected ? 2.5 : 1.5,
                              ),
                            ),
                            child: Icon(
                              cat['icon'] as IconData,
                              color: isSelected ? cat['color'] as Color : const Color(0xFF64748B),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat['name'] as String,
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
            const SizedBox(height: 16),

            const Text(
              'Nama Toko / Merchant',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _merchantController,
              style: const TextStyle(fontSize: 14, fontFamily: 'Inter', color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'cth. Kopi Kenangan',
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
              'Catatan (opsional)',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14, fontFamily: 'Inter', color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'Tambah catatan...',
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menyimpan transaksi harian...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Simpan Pengeluaran',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Hubungkan ke Modul 2 milik Lyvia (ReceiptCameraScreen)
                },
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
        ),
      ),
    );
  }
}