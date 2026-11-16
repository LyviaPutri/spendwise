import 'package:flutter/material.dart';
import 'modules/expense/screens/main_navigation.dart'; // Merujuk ke navigasi utama
import 'services/notification_handler.dart';
import 'services/local_notification_service.dart'; 

void main() async {
  // Wajib dipanggil sebelum runApp()
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Alarm harian diaktifkan 
   await LocalNotificationService.initialize();
   await LocalNotificationService.scheduleDailyNotification();

  // 2. Aktifkan pendengar notifikasi GoPay 
  NotificationHandler.startListening();

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
      // Layar awal disetel ke Navigasi Bawah
      home: const MainNavigation(), 
    );
  }
}