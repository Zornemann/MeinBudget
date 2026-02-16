class Loan {
  final String id;
  final String name;
  final double totalAmount;
  final double interestRate; // Effektiver Zinsatz in Prozent
  final int durationMonths; // Laufzeit in Monaten
  final double monthlyRate; // Monatliche Rate
  final DateTime startDate;
  final String? description;

  Loan({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.interestRate,
    required this.durationMonths,
    required this.monthlyRate,
    required this.startDate,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'totalAmount': totalAmount,
      'interestRate': interestRate,
      'durationMonths': durationMonths,
      'monthlyRate': monthlyRate,
      'startDate': startDate.toIso8601String(),
      'description': description,
    };
  }

  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'],
      name: map['name'],
      totalAmount: map['totalAmount'],
      interestRate: map['interestRate'],
      durationMonths: map['durationMonths'],
      monthlyRate: map['monthlyRate'],
      startDate: DateTime.parse(map['startDate']),
      description: map['description'],
    );
  }

  // Berechnet die verbleibende Gesamtsumme
  double getRemainingAmount(DateTime currentDate) {
    // Berechne Monate zwischen Start- und aktuellem Datum
    final yearDiff = currentDate.year - startDate.year;
    final monthDiff = currentDate.month - startDate.month;
    final monthsPassed = (yearDiff * 12) + monthDiff;
    
    if (monthsPassed >= durationMonths) {
      return 0;
    }
    final remainingMonths = durationMonths - monthsPassed;
    return monthlyRate * remainingMonths;
  }

  // Berechnet die bereits gezahlte Summe
  double getPaidAmount(DateTime currentDate) {
    return totalAmount - getRemainingAmount(currentDate);
  }
}
