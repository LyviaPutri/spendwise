import 'package:flutter/material.dart';

import '../screens/detail_screen.dart';
import '../screens/form_catatan_screen.dart';
import '../screens/form_transaksi_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/not_found_screen.dart';

/// Semua nama route dikumpulkan di satu tempat (hindari typo string).
class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String formCatatan = '/form-catatan';
  static const String formTransaksi = '/form-transaksi';

  /// Dipanggil Flutter untuk route yang tidak ada di tabel `routes`.
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => NotFoundScreen(namaRoute: settings.name),
    );
  }

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        home: (context) => const HomeScreen(),
        detail: (context) => const DetailScreen(),
        formCatatan: (context) => const FormCatatanScreen(),
        formTransaksi: (context) => const FormTransaksiScreen(),
      };
}
