import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/category_model.dart';
import '../../models/expense_model.dart';
import '../../models/receipt_model.dart'; // Import dibenarkan sesuai guide (masuk ke models/)

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

    // Dikembalikan ke version 1 karena kita gabungkan semuanya di awal
    return await openDatabase(
      path,
      version: 1, 
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. TABEL KATEGORI
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        color_hex TEXT NOT NULL
      )
    ''');

    // 2. TABEL PENGELUARAN (Modul 1 - Febi)
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        expense_date TEXT NOT NULL,
        merchant_name TEXT NOT NULL,
        notes TEXT,
        source TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT
      )
    ''');

    // 3. TABEL BUKTI STRUK (Modul 2 - Lyvia)
    // PERBAIKAN: expense_id tidak lagi NOT NULL sesuai dokumen
    await db.execute('''
      CREATE TABLE receipt_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expense_id INTEGER, 
        file_path TEXT NOT NULL,
        note TEXT,
        captured_at TEXT NOT NULL,
        extracted_amount REAL,
        FOREIGN KEY (expense_id) REFERENCES expenses (id) ON DELETE CASCADE
      )
    ''');

    // 4. TABEL PAGU ANGGARAN (Modul 3 - Nasywa)
    // PERBAIKAN: Menambahkan tabel Modul 3 yang dilupakan AI Lipi
    await db.execute('''
      CREATE TABLE budget_limits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        monthly_limit REAL NOT NULL,
        period_month_year TEXT NOT NULL,
        alert_80_sent INTEGER DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // SEEDING DATA KATEGORI
    await db.insert('categories', {'name': 'Makanan & Minuman', 'icon_name': 'restaurant', 'color_hex': '#FF5722'});
    await db.insert('categories', {'name': 'Transportasi', 'icon_name': 'directions_car', 'color_hex': '#2196F3'});
    await db.insert('categories', {'name': 'Belanja', 'icon_name': 'shopping_bag', 'color_hex': '#4CAF50'});
    await db.insert('categories', {'name': 'Tagihan & Hiburan', 'icon_name': 'confirmation_number', 'color_hex': '#9C27B0'});
  }

  // ==========================================
  // DAO KHUSUS MODUL 1 (FEBIOLA)
  // ==========================================
  Future<List<CategoryModel>> getCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');
    return result.map((json) => CategoryModel.fromJson(json)).toList();
  }

  Future<int> insertExpense(ExpenseModel expense) async {
    final db = await instance.database;
    return await db.insert('expenses', expense.toJson());
  }

  Future<List<Map<String, dynamic>>> getExpenses({String? searchQuery, int? categoryId, String? monthYear}) async {
    final db = await instance.database;
    String query = '''
      SELECT e.*, c.name as category_name, c.icon_name, c.color_hex 
      FROM expenses e 
      JOIN categories c ON e.category_id = c.id
      WHERE 1=1
    ''';
    List<dynamic> args = [];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query += ' AND (e.merchant_name LIKE ? OR e.notes LIKE ?)';
      args.addAll(['%$searchQuery%', '%$searchQuery%']);
    }
    if (categoryId != null) {
      query += ' AND e.category_id = ?';
      args.add(categoryId);
    }
    if (monthYear != null && monthYear.isNotEmpty) {
      query += ' AND e.expense_date LIKE ?';
      args.add('$monthYear%');
    }
    query += ' ORDER BY e.expense_date DESC';
    return await db.rawQuery(query, args);
  }

  Future<int> updateExpense(ExpenseModel expense) async {
    final db = await instance.database;
    return await db.update(
      'expenses',
      expense.toJson(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================
  // DAO KHUSUS MODUL 2 (LYVIA)
  // ==========================================
  Future<int> insertReceipt(Receipt receipt) async {
    final db = await instance.database;
    return await db.insert('receipt_images', receipt.toJson());
  }

  Future<List<Receipt>> getReceiptsByExpense(int expenseId) async {
    final db = await instance.database;
    final result = await db.query(
      'receipt_images',
      where: 'expense_id = ?',
      whereArgs: [expenseId],
      orderBy: 'captured_at DESC',
    );
    return result.map((json) => Receipt.fromJson(json)).toList();
  }

  Future<List<Receipt>> getAllReceipts() async {
    final db = await instance.database;
    final result = await db.query(
      'receipt_images',
      orderBy: 'captured_at DESC',
    );
    return result.map((json) => Receipt.fromJson(json)).toList();
  }
}