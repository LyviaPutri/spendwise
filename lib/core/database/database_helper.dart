import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('spendwise.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. TABEL KATEGORI (Master Data)
    await db.execute('''
      CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          icon_name TEXT NOT NULL,
          color_hex TEXT NOT NULL
      )
    ''');

    // Data Bawaan (Seeding Data) Tabel categories sesuai kontrak
    await db.insert('categories', {'id': 1, 'name': 'Makanan & Minuman', 'icon_name': 'restaurant', 'color_hex': '#FF5722'});
    await db.insert('categories', {'id': 2, 'name': 'Transportasi', 'icon_name': 'directions_car', 'color_hex': '#2196F3'});
    await db.insert('categories', {'id': 3, 'name': 'Belanja', 'icon_name': 'shopping_bag', 'color_hex': '#4CAF50'});
    await db.insert('categories', {'id': 4, 'name': 'Tagihan & Hiburan', 'icon_name': 'confirmation_number', 'color_hex': '#9C27B0'});

    // 2. TABEL PENGELUARAN (Modul 1 - Febi)
    await db.execute('''
      CREATE TABLE expenses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          expense_date TEXT NOT NULL,       -- Format ISO-8601 (YYYY-MM-DDTHH:MM:SS)
          merchant_name TEXT NOT NULL,
          notes TEXT,
          source TEXT NOT NULL,             -- Nilai: 'manual', 'quick_log', atau 'ocr'
          FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT
      )
    ''');

    // 3. TABEL BUKTI STRUK (Modul 2 - Lyvia)
    await db.execute('''
      CREATE TABLE receipt_images (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          expense_id INTEGER,               -- Boleh NULL jika struk belum dihubungkan
          file_path TEXT NOT NULL,
          captured_at TEXT NOT NULL,
          extracted_amount REAL,
          FOREIGN KEY (expense_id) REFERENCES expenses (id) ON DELETE CASCADE
      )
    ''');

    // 4. TABEL PAGU ANGGARAN (Modul 3 - Nasywa)
    await db.execute('''
      CREATE TABLE budget_limits (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_id INTEGER NOT NULL,
          monthly_limit REAL NOT NULL,
          period_month_year TEXT NOT NULL,  -- Format baku: 'YYYY-MM' (contoh: '2026-10')
          alert_80_sent INTEGER DEFAULT 0,  -- 0 = False, 1 = True
          FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
  }

  // ==========================================
  // FUNGSI DAO / QUERY KHUSUS MODUL 3 (NASYWA)
  // ==========================================

  // 1. Create: Menyimpan Pagu Anggaran Baru (FR-15)
  Future<int> insertBudgetLimit(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('budget_limits', row);
  }

  // 2. Read: Membaca Daftar Anggaran & Kategori Berdasarkan Periode (FR-16)
  Future<List<Map<String, dynamic>>> getBudgetsByPeriod(String period) async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT b.*, c.name as category_name, c.icon_name, c.color_hex 
      FROM budget_limits b
      JOIN categories c ON b.category_id = c.id
      WHERE b.period_month_year = ?
    ''', [period]);
  }

  // 3. Kontrak Titik Temu (Modul 1 -> Modul 3): Menghitung Total Realisasi Belanja dari Tabel Expenses
  Future<double> getTotalSpentByCategoryAndPeriod(int categoryId, String period) async {
    Database db = await instance.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM expenses 
      WHERE category_id = ? AND expense_date LIKE ?
    ''', [categoryId, '$period%']);

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }
}