import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/database/database_helper.dart';
import '../../../models/receipt_model.dart';
import '../services/receipt_file_service.dart';
import '../services/receipt_validator.dart';

class ReceiptEditScreen extends StatefulWidget {
  final Receipt receipt; // DATA MASUK: struk yang mau diedit

  const ReceiptEditScreen({super.key, required this.receipt});

  @override
  State<ReceiptEditScreen> createState() => _ReceiptEditScreenState();
}

class _ReceiptEditScreenState extends State<ReceiptEditScreen> {
  late final TextEditingController _noteController; // STATE: isi catatan
  String? _newPhotoPath; // STATE: foto baru yang dipilih (null = belum ganti)
  bool _isSaving = false; // STATE: true saat proses simpan berjalan
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Isi awal catatan = catatan lama
    _noteController = TextEditingController(text: widget.receipt.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showMessage(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  // EVENT: tombol "Ganti foto". Foto baru cuma ditampung dulu,
  // baru disalin dan disimpan saat tombol Simpan ditekan.
  Future<void> _pickNewPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return; // dibatalkan

    final check = await ReceiptValidator.filterValid([picked]);
    if (!mounted) return;
    if (check.validPaths.isEmpty) {
      _showMessage('Foto ditolak (harus JPG/PNG, maks 5 MB)', isError: true);
      return;
    }
    setState(() => _newPhotoPath = check.validPaths.first);
  }

  // EVENT: tombol "Simpan Perubahan"
  Future<void> _save() async {
    setState(() => _isSaving = true);

    final oldPath = widget.receipt.imagePath;
    String finalPath = oldPath;

    // 1. Kalau ganti foto: salin foto baru ke folder aplikasi
    if (_newPhotoPath != null) {
      finalPath = await ReceiptFileService.copyToAppDir(_newPhotoPath!);
    }

    // 2. Update database (path + catatan)
    await DatabaseHelper.instance.updateReceipt(
      widget.receipt.id!,
      finalPath,
      _noteController.text.trim(),
    );

    // 3. Baru hapus file lama (hanya kalau fotonya diganti)
    if (_newPhotoPath != null) {
      try {
        final oldFile = File(oldPath);
        if (await oldFile.exists()) await oldFile.delete();
      } catch (_) {}
    }

    if (!mounted) return;
    // RESULT: kembali ke galeri sambil memberi tahu "sudah tersimpan"
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan foto baru kalau ada, kalau belum tampilkan foto lama
    final shownPath = _newPhotoPath ?? widget.receipt.imagePath;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Struk')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _newPhotoPath == null ? 'Foto struk' : 'Foto baru',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Image.file(
                            File(shownPath),
                            height: 220,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stack) =>
                                const Icon(Icons.broken_image,
                                    size: 80, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton.icon(
                            onPressed: _isSaving ? null : _pickNewPhoto,
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('Ganti foto'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _noteController,
                          maxLength: 100,
                          decoration: const InputDecoration(
                            labelText: 'Catatan foto (opsional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                    : const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}