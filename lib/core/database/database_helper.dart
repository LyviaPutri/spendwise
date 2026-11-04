import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/expense_model.dart';
import '../../models/category_model.dart';

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
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        color_hex TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        expense_date TEXT NOT NULL,
        merchant_name TEXT NOT NULL,
        payment_method TEXT,
        notes TEXT,
        source TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT
      )
    ''');

    await db.insert('categories', {'name': 'Makanan', 'icon_name': 'restaurant', 'color_hex': '#F59E0B'});
    await db.insert('categories', {'name': 'Transport', 'icon_name': 'directions_car', 'color_hex': '#2196F3'});
    await db.insert('categories', {'name': 'Belanja', 'icon_name': 'shopping_bag', 'color_hex': '#4CAF50'});
    await db.insert('categories', {'name': 'Hiburan', 'icon_name': 'confirmation_number', 'color_hex': '#9C27B0'});
    await db.insert('categories', {'name': 'Lainnya', 'icon_name': 'grid_view_rounded', 'color_hex': '#64748B'});
  }

  Future<List<CategoryModel>> getCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');
    return result.map((json) => CategoryModel.fromJson(json)).toList();
  }

  Future<int> insertExpense(ExpenseModel expense) async {
    final db = await instance.database;
    return await db.insert('expenses', expense.toJson());
  }

  Future < List < Map < String, dynamic > > > getExpenses() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT expenses.*, categories.name AS category_name, categories.icon_name, categories.color_hex
      FROM expenses
      INNER JOIN categories ON expenses.category_id = categories.id
      ORDER BY expenses.expense_date DESC
    ''');
  }

  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateExpenseRaw(int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update('expenses', data, where: 'id = ?', whereArgs: [id]);
  }
}