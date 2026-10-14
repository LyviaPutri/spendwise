import 'package:flutter/material.dart';
import 'modules/budget/screens/budget_limit_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SpendWiseApp());
}

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendWise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Mengarahkan halaman utama aplikasi langsung ke BudgetLimitScreen (Modul 3)
      home: const BudgetLimitScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}