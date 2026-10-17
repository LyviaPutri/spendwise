class Receipt {
  final int expenseId;      // transaksi pemilik lampiran
  final String imagePath;   // = file_path di PRD
  final String note;
  final DateTime createdAt; // = captured_at di PRD

  Receipt({
    required this.expenseId,
    required this.imagePath,
    required this.note,
    required this.createdAt,
  });
}