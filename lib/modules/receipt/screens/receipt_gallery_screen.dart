import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../models/receipt_model.dart';

class ReceiptGalleryScreen extends StatefulWidget {
  const ReceiptGalleryScreen({super.key});

  @override
  State<ReceiptGalleryScreen> createState() => _ReceiptGalleryScreenState();
}

class _ReceiptGalleryScreenState extends State<ReceiptGalleryScreen> {
  List<Receipt> _receipts = []; // STATE: semua struk dari database
  bool _isLoading = true;       // STATE: true saat data sedang dibaca

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    final data = await DatabaseHelper.instance.getAllReceipts();
    if (!mounted) return;
    setState(() {
      _receipts = data;
      _isLoading = false;
    });
  }

  // Foto yang file-nya hilang tidak bikin app error
  Widget _buildImage(String path, {BoxFit fit = BoxFit.cover}) {
    return Image.file(
      File(path),
      fit: fit,
      errorBuilder: (context, error, stack) => const Center(
        child: Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }

  void _openPreview(Receipt r) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 300,
                width: double.infinity,
                child: _buildImage(r.imagePath, fit: BoxFit.contain),
              ),
              const SizedBox(height: 12),
              Text(r.note.isEmpty ? 'Tanpa catatan' : r.note),
              const SizedBox(height: 4),
              Text(
                'Dilampirkan ${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galeri Struk')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _receipts.isEmpty
              ? const Center(child: Text('Belum ada struk tersimpan'))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _receipts.length,
                  itemBuilder: (context, i) {
                    final r = _receipts[i];
                    return InkWell(
                      onTap: () => _openPreview(r),
                      child: _buildImage(r.imagePath),
                    );
                  },
                ),
    );
  }
}