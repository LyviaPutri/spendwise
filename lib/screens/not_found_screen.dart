import 'package:flutter/material.dart';

import '../routes/app_routes.dart';

/// Halaman 404: tampil saat route yang dibuka tidak terdaftar.
class NotFoundScreen extends StatelessWidget {
  final String? namaRoute;

  const NotFoundScreen({super.key, this.namaRoute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('404', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 8),
              Text(
                'Halaman "${namaRoute ?? '-'}" tidak ditemukan.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                ),
                child: const Text('Kembali ke Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
