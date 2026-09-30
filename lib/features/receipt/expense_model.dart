class Expense {
  final int id;
  final String merchant;
  final int amount;
  final String category;
  final String date;
  final String notes;
  final String paymentMethod; // Tunai / GoPay / QRIS, dll

  const Expense({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.category,
    required this.date,
    required this.notes,
    required this.paymentMethod,
  });

  // Format 25000 -> Rp25.000
  String get amountText {
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp$buf';
  }
}