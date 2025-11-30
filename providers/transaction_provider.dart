import 'package:flutter/foundation.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => [..._transactions];

  double get balance {
    return _transactions.fold(0.0, (sum, item) => sum + (item.type == 'income' ? item.amount : -item.amount));
  }

  double get totalIncome {
    return _transactions.where((tx) => tx.type == 'income').fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpenses {
    return _transactions.where((tx) => tx.type == 'expense').fold(0.0, (sum, item) => sum + item.amount);
  }

  void addTransaction(Transaction transaction) {
    final newTransaction = Transaction(
      id: DateTime.now().toString(),
      type: transaction.type,
      category: transaction.category,
      amount: transaction.amount,
      date: transaction.date,
      description: transaction.description,
    );
    _transactions.add(newTransaction);
    _sortTransactions();
    notifyListeners();
  }

  void updateTransaction(Transaction transaction) {
    final txIndex = _transactions.indexWhere((tx) => tx.id == transaction.id);
    if (txIndex >= 0) {
      _transactions[txIndex] = transaction;
      _sortTransactions();
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }

  void _sortTransactions() {
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }
}
