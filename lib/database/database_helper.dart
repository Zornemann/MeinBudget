import 'package:sqflite/sqflite.dart' hide Transaction;

// other existing code...

  Future<List<Transaction>> getTransactions() async {
    final result = await database.query('transactions');
    return result.map<Transaction>((json) => Transaction.fromMap(json)).toList();
  }

// ...