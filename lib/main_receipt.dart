import 'package:flutter/material.dart';
import 'features/receipt/expense_model.dart';
import 'features/receipt/expense_detail_screen.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ExpenseDetailScreen(
      // Data dummy: nanti diganti data dari modul pengeluaran
      expense: Expense(
        id: 1,
        merchant: 'Indomaret',
        amount: 25000,
        category: 'Belanja',
        date: '5 Okt 2026',
        notes: 'Beli snack dan minum',
        paymentMethod: 'Tunai',
      ),
    ),
  ));
}