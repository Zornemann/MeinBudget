class Category {
  final String id;
  final String name;
  final String type; // 'income' or 'expense'
  final bool isCustom;

  Category({
    required this.id,
    required this.name,
    required this.type,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'isCustom': isCustom ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      isCustom: map['isCustom'] == 1,
    );
  }
}
