
import 'package:flutter/material.dart';
import '../models/transaction.dart' as txn;
import '../helpers/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<txn.Transaction> _transactions = [];
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;

  List<txn.Transaction> get transactions => _transactions;
  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;
  double get balance => _totalIncome - _totalExpenses;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  TransactionProvider() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    _transactions = await _dbHelper.getTransactions();
    await _updateTotals();
    notifyListeners();
  }

  Future<void> _updateTotals() async {
    _totalIncome = await _dbHelper.getTotalIncome();
    _totalExpenses = await _dbHelper.getTotalExpenses();
  }

  Future<void> addTransaction(txn.Transaction transaction) async {
    await _dbHelper.addTransaction(transaction);
    await _loadTransactions(); 
  }

  Future<void> updateTransaction(txn.Transaction transaction) async {
    await _dbHelper.updateTransaction(transaction);
    await _loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _dbHelper.deleteTransaction(id);
    await _loadTransactions();
  }
}
