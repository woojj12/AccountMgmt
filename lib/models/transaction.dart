
class Transaction {
  int? id;
  final String type;
  final String category;
  final double amount;
  final DateTime date;
  final String? description;

  Transaction({
    this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
  });

  // Convert a Transaction object into a Map object.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  // Extract a Transaction object from a Map object.
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: map['type'],
      category: map['category'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      description: map['description'],
    );
  }
}
