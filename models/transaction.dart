import 'package:flutter/foundation.dart';

class Transaction {
  final String? id;
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
}
