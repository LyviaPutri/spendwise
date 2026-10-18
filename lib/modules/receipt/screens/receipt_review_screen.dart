import 'dart:io';
import 'package:flutter/material.dart';
import '../dummy_expense.dart';
import '../../../models/receipt_model.dart';

class ReceiptReviewScreen extends StatefulWidget {
  final List<String> imagePaths; // DATA MASUK 1: daftar path foto
  final Expense expense;         // DATA MASUK 2: transaksi terkait

  const ReceiptReviewScreen({
    super.key,
    required this.imagePaths,
    required this.expense,
  });

  @override
  State<ReceiptReviewScreen> createState() => _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends State<ReceiptReviewScreen> {
  // STATE: satu controller catatan untuk setiap foto (urutan sama dengan imagePaths)
  late final List<TextEditingController> _noteControllers;
  bool _isSaving = false; // STATE: true saat proses simpan berjalan

  @override
  void initState() {
    super.initState();
    _noteControllers = List.generate(
      widget.imagePaths.length,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (final c in _noteControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true); // FEEDBACK: loading
    await Future.delayed(const Duration(seconds: 1)); // simulasi proses simpan
    if (!mounted) return;

    final now = DateTime.now();

    // Satu Receipt per foto, dengan catatannya masing-masing
    final receipts = List.generate(widget.imagePaths.length, (i) {
      return Receipt(
        expenseId: widget.expense.id,
        imagePath: widget.imagePaths[i],
        note: _noteControllers[i].text.trim(),
        createdAt: now,
      );
    });

    // RESULT: kembali ke Detail sambil membawa daftar Receipt
    Navigator.pop(context, receipts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Lampiran')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dilampirkan ke: ${widget.expense.merchant} '
                '(${widget.expense.amountText})'),
            const SizedBox(height: 4),
            Text('${widget.imagePaths.length} foto dipilih',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Daftar foto, masing-masing punya kolom catatan sendiri
            Expanded(
              child: ListView.builder(
                itemCount: widget.imagePaths.length,
                itemBuilder: (context, i) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Foto ${i + 1}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Center(
                            child: Image.file(
                              File(widget.imagePaths[i]),
                              height: 220,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _noteControllers[i],
                            maxLength: 100,
                            decoration: InputDecoration(
                              labelText: 'Catatan foto ${i + 1} (opsional)',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save, // disabled saat loading
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Lampirkan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}