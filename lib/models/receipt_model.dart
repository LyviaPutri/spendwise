class Receipt {
  final int? id;               // null saat belum disimpan, diisi otomatis oleh database
  final int? expenseId;        // = expense_id, boleh null (struk belum ditautkan)        // = expense_id
  final String imagePath;      // = file_path
  final String note;
  final DateTime createdAt;    // = captured_at
  final double? extractedAmount; // hasil OCR, boleh kosong

  Receipt({
    this.id,
    required this.expenseId,
    required this.imagePath,
    required this.note,
    required this.createdAt,
    this.extractedAmount,
  });

  // Baris tabel -> objek Receipt
  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as int?,
      expenseId: json['expense_id'] as int?,
      imagePath: json['file_path'] as String,
      note: (json['note'] as String?) ?? '',
      createdAt: DateTime.parse(json['captured_at'] as String),
      extractedAmount: (json['extracted_amount'] as num?)?.toDouble(),
    );
  }

  // Objek Receipt -> baris tabel
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expense_id': expenseId,
      'file_path': imagePath,
      'note': note,
      'captured_at': createdAt.toIso8601String(),
      'extracted_amount': extractedAmount,
    };
  }
}