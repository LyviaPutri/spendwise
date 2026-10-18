class ExpenseModel {
  final int? id;
  final int categoryId;
  final double amount;
  final String expenseDate;
  final String merchantName;
  final String? notes;
  final String source;

  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;

  ExpenseModel({
    this.id,
    required this.categoryId,
    required this.amount,
    required this.expenseDate,
    required this.merchantName,
    this.notes,
    this.source = 'manual',
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        id: json['id'] as int?,
        categoryId: json['category_id'] as int,
        amount: (json['amount'] as num).toDouble(),
        expenseDate: json['expense_date'] as String,
        merchantName: json['merchant_name'] as String,
        notes: json['notes'] as String?,
        source: json['source'] as String,
        categoryName: json['category_name'] as String?,
        categoryIcon: json['icon_name'] as String?,
        categoryColor: json['color_hex'] as String?,
      );

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