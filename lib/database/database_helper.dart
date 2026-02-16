import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/transaction.dart';
import '../models/loan.dart';
import '../models/category.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mein_budget.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      // Für Web: verwende sqflite_common_ffi_web
      final factory = databaseFactoryFfiWeb;
      return await factory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: _createDB,
        ),
      );
    } else {
      // Für Mobile: verwende standard sqflite
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 2,
        onCreate: _createDB,
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // 1. NEU: Tabelle für Konten
    await db.execute('''
      CREATE TABLE accounts (
        id $idType,
        name $textType,
        icon $textType,
        initialBalance $realType
      )
    ''');

    // 2. Transaktionen (mit accountId Erweiterung)
    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        accountId $textType, -- Verknüpfung zum Konto
        type $textType,
        category $textType,
        amount $realType,
        description $textType,
        date $textType
      )
    ''');

    // ... Kredite und Kategorien bleiben gleich wie in deinem Code ...
    await db.execute('''
      CREATE TABLE loans (
        id $idType, name $textType, totalAmount $realType, interestRate $realType,
        durationMonths $intType, monthlyRate $realType, startDate $textType, description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id $idType, name $textType, type $textType, isCustom $intType
      )
    ''');

    // Standard-Konto und Kategorien anlegen
    await _insertDefaultData(db);
  }

  Future<void> _insertDefaultData(Database db) async {
    // Standard-Konto erstellen, damit die App direkt funktioniert
    await db.insert('accounts', {
      'id': 'default_main',
      'name': 'Hauptkonto',
      'icon': 'account_balance',
      'initialBalance': 0.0,
    });

    await _insertDefaultCategories(db);
  }
    // --- KONTEN CRUD ---
  Future<void> insertAccount(Map<String, dynamic> account) async {
    final db = await database;
    await db.insert('accounts', account);
  }

  Future<List<Map<String, dynamic>>> getAccounts() async {
    final db = await database;
    return await db.query('accounts', orderBy: 'name ASC');
  }

  // WICHTIG: Deine getTransactions() Methode muss ggf. angepasst werden
  Future<List<Transaction>> getTransactions() async {
    final db = await database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map<Transaction>((json) => Transaction.fromMap(json)).toList();
  }
  
  // Hilfsfunktion: Berechne Saldo eines Kontos
  Future<double> getAccountBalance(String accountId) async {
    final transactions = await getTransactions();
    final accountTransactions = transactions.where((t) => t.accountId == accountId);
    
    double balance = 0;
    for (var t in accountTransactions) {
      balance += (t.type == 'income' ? t.amount : -t.amount);
    }
    return balance;
  }
 // --- KREDITE (LOANS) CRUD ---
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

  // --- KATEGORIEN CRUD ---
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

  Future<void> _insertDefaultCategories(Database db) async {
    final List<Map<String, dynamic>> defaults = [
      {'id': 'income_gehalt', 'name': 'Gehalt', 'type': 'income', 'isCustom': 0},
      {'id': 'income_kindergeld', 'name': 'Kindergeld', 'type': 'income', 'isCustom': 0},
      {'id': 'expense_kredite', 'name': 'Kredite', 'type': 'expense', 'isCustom': 0},
      {'id': 'expense_einkauf', 'name': 'Einkauf', 'type': 'expense', 'isCustom': 0},
      {'id': 'expense_tanken', 'name': 'Tanken', 'type': 'expense', 'isCustom': 0},
      {'id': 'expense_versicherung', 'name': 'Versicherung', 'type': 'expense', 'isCustom': 0},
    ];
    for (var cat in defaults) {
      await db.insert('categories', cat, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
  Future<void> transferMoney({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String description,
  }) async {
    final db = await database;
    final date = DateTime.now().toIso8601String();
    final transferId = DateTime.now().millisecondsSinceEpoch.toString();

    await db.transaction((txn) async {
      // 1. Abgang vom Quellkonto
      await txn.insert('transactions', {
        'id': '${transferId}_out',
        'accountId': fromAccountId,
        'type': 'expense',
        'category': 'Umbuchung',
        'amount': amount,
        'description': 'An: $description',
        'date': date,
      });

      // 2. Eingang auf Zielkonto
      await txn.insert('transactions', {
        'id': '${transferId}_in',
        'accountId': toAccountId,
        'type': 'income',
        'category': 'Umbuchung',
        'amount': amount,
        'description': 'Von: $description',
        'date': date,
      });
    });
  }
  Future<void> close() async {
    final db = await database;
    db.close();
  }
} // Ende der Klasse DatabaseHelper