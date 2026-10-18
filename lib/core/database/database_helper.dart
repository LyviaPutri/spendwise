import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/category_model.dart';
import '../../models/expense_model.dart';
import '../../features/receipt/receipt_model.dart';

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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
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

    // 2. TABEL PENGELUARAN (Modul 1)
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

    await _createReceiptTable(db);
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
      args.add('%$searchQuery%');
      args.add('%$searchQuery%');
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

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createReceiptTable(db);
    }
  }

  Future<void> _createReceiptTable(Database db) async {
    await db.execute('''
      CREATE TABLE receipt_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expense_id INTEGER NOT NULL,
        file_path TEXT NOT NULL,
        note TEXT,
        captured_at TEXT NOT NULL,
        extracted_amount REAL,
        FOREIGN KEY (expense_id) REFERENCES expenses (id) ON DELETE CASCADE
      )
    ''');
  }

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
}