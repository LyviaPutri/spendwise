import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spendwise/main.dart';

void main() {
  testWidgets('Login tervalidasi lalu masuk ke Home', (tester) async {
    await tester.pumpWidget(const SpendWiseApp());

    // Submit kosong -> muncul pesan validasi.
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    expect(find.text('Email tidak boleh kosong'), findsOneWidget);
    expect(find.text('Password tidak boleh kosong'), findsOneWidget);

    // Isi akun demo -> pindah ke Home (loading dulu).
    await tester.enterText(
        find.byType(TextFormField).at(0), 'mahasiswa@spendwise.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Memuat transaksi...'), findsOneWidget);

    // Setelah delay selesai, data tampil.
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Makan siang di kantin'), findsOneWidget);
  });
}
