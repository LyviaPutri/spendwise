class ExpenseModel {
  final int? id;
  final int categoryId;
  final double amount;
  final String expenseDate;
  final String merchantName;
  final String? notes;
  final String source;

  ExpenseModel({
    this.id,
    required this.categoryId,
    required this.amount,
    required this.expenseDate,
    required this.merchantName,
    this.notes,
    required this.source,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as int?,
      categoryId: json['category_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      expenseDate: json['expense_date'] as String,
      merchantName: json['merchant_name'] as String,
      notes: json['notes'] as String?,
      source: json['source'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
      'expense_date': expenseDate,
      'merchant_name': merchantName,
      'notes': notes,
      'source': source,
    };
  }
}