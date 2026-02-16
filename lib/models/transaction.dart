class Transaction {
  final String id;
  final String accountId; // ✅ Neu hinzugefügt
  final String type; // 'income' or 'expense'
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  Transaction({
    required this.id,
    required this.accountId, // ✅ ebenfalls required
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId, // ✅ hinzugefügt
      'type': type,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      accountId: map['accountId'], // ✅ hinzugefügt
      type: map['type'],
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      description: map['description'],
      date: DateTime.parse(map['date']),
    );
  }
}