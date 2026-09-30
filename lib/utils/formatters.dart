/// Format angka & tanggal tanpa package tambahan.
class Formatters {
  static const _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  /// 1500000 -> "Rp 1.500.000"
  static String rupiah(int angka) {
    final s = angka.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return 'Rp $buffer';
  }

  /// DateTime(2026, 9, 28) -> "28 September 2026"
  static String tanggal(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

  /// "28 September 2026, 09:05"
  static String tanggalWaktu(DateTime d) {
    final jam = d.hour.toString().padLeft(2, '0');
    final menit = d.minute.toString().padLeft(2, '0');
    return '${tanggal(d)}, $jam:$menit';
  }
}
