class Account {
  final int? id;
  final String name;
  final String icon; // Icon-Name als String
  final double initialBalance;

  Account({this.id, required this.name, required this.icon, this.initialBalance = 0.0});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'icon': icon, 'initial_balance': initialBalance};
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      initialBalance: map['initial_balance'],
    );
  }
}