import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../dummy_expense.dart';
import '../../../models/receipt_model.dart';
import 'receipt_review_screen.dart';
import 'receipt_gallery_screen.dart';
import '../../../core/database/database_helper.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Expense expense; // DATA MASUK: transaksi yang dilihat
  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  static const int _maxReceipts = 3;
  static const int _maxSizeBytes = 5 * 1024 * 1024; // 5 MB

  // STATE: daftar lampiran struk milik transaksi ini
  final List<Receipt> _receipts = [];
  final ImagePicker _picker = ImagePicker();

    @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  // Baca semua struk milik transaksi ini dari database
  Future<void> _loadReceipts() async {
    final data =
        await DatabaseHelper.instance.getReceiptsByExpense(widget.expense.id);
    if (!mounted) return;
    setState(() {
      _receipts
        ..clear()
        ..addAll(data);
    });
  }

  void _showMessage(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  // INPUT/EVENT: dipanggil saat tombol "Lampirkan Struk" ditekan
  Future<void> _attachReceipt() async {
    // Sisa kuota = batas - yang sudah terlampir
    final int remaining = _maxReceipts - _receipts.length;

    // VALIDASI 1: kuota sudah penuh
    if (remaining <= 0) {
      _showMessage('Maksimal $_maxReceipts lampiran per transaksi',
          isError: true);
      return;
    }

    // Pilih beberapa foto sekaligus, maksimal sebanyak sisa kuota
    // (limit minimal 2 di image_picker, jadi sisa 1 pakai pickImage)
    List<XFile> picked;
    if (remaining == 1) {
      final single = await _picker.pickImage(source: ImageSource.gallery);
      picked = single == null ? [] : [single];
    } else {
      picked = await _picker.pickMultiImage(limit: remaining);
    }
    if (!mounted) return;

    // VALIDASI 2: user batal memilih foto
    if (picked.isEmpty) {
      _showMessage('Tidak ada foto dipilih');
      return;
    }

    // VALIDASI 3: jaga-jaga kalau galeri melebihi sisa kuota
    if (picked.length > remaining) {
      picked = picked.sublist(0, remaining);
      _showMessage('Hanya $remaining foto yang diambil (sisa kuota)');
    }

    // VALIDASI 4 + 5: format JPG/PNG dan ukuran maksimal 5 MB
    final List<String> validPaths = [];
    int rejected = 0;
    for (final file in picked) {
      final path = file.path.toLowerCase();
      final validFormat = path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png');
      final size = await File(file.path).length();
      if (validFormat && size <= _maxSizeBytes) {
        validPaths.add(file.path);
      } else {
        rejected++;
      }
    }
    if (!mounted) return;

    if (rejected > 0) {
      _showMessage('$rejected foto ditolak (harus JPG/PNG, maks 5 MB)',
          isError: true);
    }
    if (validPaths.isEmpty) return; // semua ditolak, tetap di Detail

    // NAVIGATION: kirim daftar imagePath + expense ke Review Screen,
    // lalu tunggu daftar Receipt yang dikembalikan lewat pop
    final result = await Navigator.push<List<Receipt>>(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptReviewScreen(
          imagePaths: validPaths,
          expense: widget.expense,
        ),
      ),
    );

    if (!mounted) return;
    // RESULT: tambahkan semua Receipt yang dikembalikan ke state
    if (result != null && result.isNotEmpty) {
      for (final r in result) {
        await DatabaseHelper.instance.insertReceipt(r);
      }
      await _loadReceipts(); // baca ulang dari database
      if (!mounted) return;
      _showMessage('${result.length} struk berhasil dilampirkan!');
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.expense;
    return Scaffold(
      appBar: AppBar(
  title: const Text('Detail Transaksi'),
  actions: [
    IconButton(
      icon: const Icon(Icons.photo_library),
      tooltip: 'Galeri Struk',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReceiptGalleryScreen()),
        );
      },
    ),
  ],
),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // INFO LENGKAP TRANSAKSI
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.merchant,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(e.amountText,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  _infoRow('Kategori', e.category),
                  _infoRow('Tanggal', e.date),
                  _infoRow('Metode Bayar', e.paymentMethod),
                  _infoRow('Catatan', e.notes.isEmpty ? '-' : e.notes),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // TOMBOL LAMPIRKAN
          ElevatedButton.icon(
            onPressed: _attachReceipt,
            icon: const Icon(Icons.attach_file),
            label: const Text('Lampirkan Struk'),
          ),
          const SizedBox(height: 16),

          // DAFTAR LAMPIRAN
          Text('Bukti Struk (${_receipts.length}/$_maxReceipts)',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_receipts.isEmpty)
            const Text('Belum ada lampiran',
                style: TextStyle(color: Colors.grey))
          else
            ..._receipts.map((r) => Card(
                  child: ListTile(
                    leading: Image.file(File(r.imagePath),
                        width: 56, height: 56, fit: BoxFit.cover),
                    title: Text(r.note.isEmpty ? 'Tanpa catatan' : r.note),
                    subtitle: Text(
                        'Dilampirkan ${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}'),
                  ),
                )),
        ],
      ),
    );
  }
}