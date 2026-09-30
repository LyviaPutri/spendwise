/// Kumpulan fungsi validasi untuk TextFormField.
class Validators {
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email tidak boleh kosong';
    final pola = RegExp(r'^[\w.\-]+@[\w\-]+(\.[\w\-]+)+$');
    if (!pola.hasMatch(v)) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password tidak boleh kosong';
    return null;
  }

  static String? judul(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Judul tidak boleh kosong';
    return null;
  }

  static String? nominal(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Nominal tidak boleh kosong';
    final angka = int.tryParse(v);
    if (angka == null) return 'Nominal harus berupa angka';
    if (angka <= 0) return 'Nominal harus lebih dari 0';
    return null;
  }

  static String? catatan(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Catatan tidak boleh kosong';
    if (v.length < 3) return 'Catatan minimal 3 karakter';
    return null;
  }
}
