import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/transaction.dart' as models;
import '../models/loan.dart';
import '../models/category.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static sqflite.Database? _database;

  DatabaseHelper._init();

  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mein_budget.db');
    return _database!;
  }

  Future<sqflite.Database> _initDB(String filePath) async {
    if (kIsWeb) {
      // Für Web: verwende sqflite_common_ffi_web
      final factory = databaseFactoryFfiWeb;
      return await factory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDB,
        ),
      );
    } else {
      // Für Mobile: verwende standard sqflite
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    }
  }

  Future<void> _createDB(sqflite.Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // Tabelle für Transaktionen (Einnahmen und Ausgaben)
    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        type $textType,
        category $textType,
        amount $realType,
        description $textType,
        date $textType
      )
    ''');

    // Tabelle für Kredite
    await db.execute('''
      CREATE TABLE loans (
        id $idType,
        name $textType,
        totalAmount $realType,
        interestRate $realType,
        durationMonths $intType,
        monthlyRate $realType,
        startDate $textType,
        description TEXT
      )
    ''');

    // Tabelle für Kategorien
    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        type $textType,
        isCustom $intType
      )
    ''');

    // Vordefinierte Kategorien einfügen
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(sqflite.Database db) async {
    // Einnahmen-Kategorien
    await db.insert('categories', {
      'id': 'income_gehalt',
      'name': 'Gehalt',
      'type': 'income',
      'isCustom': 0,
    });
    await db.insert('categories', {
      'id': 'income_kindergeld',
      'name': 'Kindergeld',
      'type': 'income',
      'isCustom': 0,
    });

    // Ausgaben-Kategorien
    await db.insert('categories', {
      'id': 'expense_kredite',
      'name': 'Kredite',
      'type': 'expense',
      'isCustom': 0,
    });
    await db.insert('categories', {
      'id': 'expense_einkauf',
      'name': 'Einkauf',
      'type': 'expense',
      'isCustom': 0,
    });
    await db.insert('categories', {
      'id': 'expense_tanken',
      'name': 'Tanken',
      'type': 'expense',
      'isCustom': 0,
    });
    await db.insert('categories', {
      'id': 'expense_versicherung',
      'name': 'Versicherung',
      'type': 'expense',
      'isCustom': 0,
    });
    await db.insert('categories', {
      'id': 'expense_unterhaltung',
      'name': 'Unterhaltung',
      'type': 'expense',
      'isCustom': 0,
    });
    await db.insert('categories', {
      'id': 'expense_spareinlagen',
      'name': 'Spareinlagen',
      'type': 'expense',
      'isCustom': 0,
    });
  }

  // CRUD Operationen für Transaktionen
  Future<void> insertTransaction(models.Transaction transaction) async {
    final db = await database;
    await db.insert('transactions', transaction.toMap());
  }

  Future<List<models.Transaction>> getTransactions() async {
    final db = await database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) => models.Transaction.fromMap(json)).toList();
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Operationen für Kredite
  Future<void> insertLoan(Loan loan) async {
    final db = await database;
    await db.insert('loans', loan.toMap());
  }

  Future<List<Loan>> getLoans() async {
    final db = await database;
    final result = await db.query('loans', orderBy: 'startDate DESC');
    return result.map((json) => Loan.fromMap(json)).toList();
  }

  Future<void> deleteLoan(String id) async {
    final db = await database;
    await db.delete('loans', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD Operationen für Kategorien
  Future<void> insertCategory(Category category) async {
    final db = await database;
    await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories(String type) async {
    final db = await database;
    final result = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'isCustom, name',
    );
    return result.map((json) => Category.fromMap(json)).toList();
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
