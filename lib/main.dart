import 'package:flutter/material.dart';
import 'modules/expense/screens/expense_list_screen.dart'; 

void main() async {
  // Wajib dipanggil jika ada eksekusi asynchronous sebelum runApp()
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SpendWiseApp());
}

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      // Layar awal harus merujuk ke ExpenseListScreen
      home: const ExpenseListScreen(), 
    );
  }
}