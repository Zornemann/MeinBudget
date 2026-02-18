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
      final factory = databaseFactoryFfiWeb;
      return await factory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: _createDB,
        ),
      );
    } else {
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

    await db.execute('''
      CREATE TABLE accounts (
        id $idType,
        name $textType,
        icon $textType,
        initialBalance $realType
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        accountId $textType,
        type $textType,
        category $textType,
        amount $realType,
        description $textType,
        date $textType
      )
    ''');

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

    await db.execute('''
      CREATE TABLE categories (
        id $idType, 
        name $textType, 
        type $textType, 
        isCustom $intType
      )
    ''');

    await _insertDefaultData(db);
  }

  Future<void> _insertDefaultData(Database db) async {
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
    await db.insert('accounts', account, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAccounts() async {
    final db = await database;
    return await db.query('accounts', orderBy: 'name ASC');
  }

  Future<void> deleteAccount(String accountId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('transactions', where: 'accountId = ?', whereArgs: [accountId]);
      await txn.delete('accounts', where: 'id = ?', whereArgs: [accountId]);
    });
  }

  // --- TRANSAKTIONEN CRUD ---
  Future<void> insertTransaction(Transaction transaction) async {
    final db = await database;
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Transaction>> getTransactions() async {
    final db = await database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) => Transaction.fromMap(json)).toList();
  }

  Future<double> getAccountBalance(String accountId) async {
    final transactions = await getTransactions();
    final accountTransactions = transactions.where((t) => t.accountId == accountId);
    
    double balance = 0;
    for (var t in accountTransactions) {
      balance += (t.type == 'income' ? t.amount : -t.amount);
    }
    return balance;
  }

  Future<double> getTotalBalance() async {
    final db = await database;
    final List<Map<String, dynamic>> accounts = await db.query('accounts');
    double totalInitialBalance = 0;
    for (var acc in accounts) {
      totalInitialBalance += (acc['initialBalance'] as num).toDouble();
    }
    final transactions = await getTransactions();
    double transactionSum = 0;
    for (var t in transactions) {
      transactionSum += (t.type == 'income' ? t.amount : -t.amount);
    }
    return totalInitialBalance + transactionSum;
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Prüft, ob ein Kredit diesen Monat bereits verbucht wurde
  Future<bool> hasLoanBeenPaidThisMonth(String loanId) async {
    final db = await database;
    final now = DateTime.now();
    // Erster Tag des aktuellen Monats als ISO String
    final firstDayOfMonth = DateTime(now.year, now.month, 1).toIso8601String();

    final List<Map<String, dynamic>> result = await db.query(
      'transactions',
      where: 'description LIKE ? AND date >= ?',
      whereArgs: ['%ID: $loanId%', firstDayOfMonth],
    );

    return result.isNotEmpty;
  }

  // --- KREDITE CRUD ---
  Future<void> insertLoan(Loan loan) async {
    final db = await database;
    await db.insert('loans', loan.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
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

  // --- GELDTRANSFER ---
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
      await txn.insert('transactions', {
        'id': '${transferId}_out',
        'accountId': fromAccountId,
        'type': 'expense',
        'category': 'Umbuchung',
        'amount': amount,
        'description': 'An: $description',
        'date': date,
      });

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
}