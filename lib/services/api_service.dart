import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense_model.dart';

class ApiService {
  // Menggunakan IP Wi-Fi laptopmu agar HP bisa terhubung
  static const String baseUrl = 'http://10.28.21.1/spendwise';

  static Future<bool> syncExpenseToServer(ExpenseModel expense) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save_expense.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'category_id': expense.categoryId,
          'amount': expense.amount,
          'expense_date': expense.expenseDate,
          'merchant_name': expense.merchantName,
          'payment_method': expense.paymentMethod ?? '-',
          'notes': expense.notes ?? '',
          'source': expense.source,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Error sinkronisasi server: $e');
      return false;
    }
  }
}