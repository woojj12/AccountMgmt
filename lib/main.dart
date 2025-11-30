
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'providers/transaction_provider.dart';
import 'models/transaction.dart' as txn;

void main() {
  // Ensure that plugin services are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: MaterialApp(
        title: '용돈 관리 앱',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 용돈 관리'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          const SummaryCard(),
          const Expanded(child: TransactionList()),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => _showTransactionDialog(context, 'income'),
            label: const Text('수입 추가'),
            icon: const Icon(Icons.add),
            backgroundColor: Colors.green,
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () => _showTransactionDialog(context, 'expense'),
            label: const Text('지출 추가'),
            icon: const Icon(Icons.remove),
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final formatter = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '현재 잔액',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              formatter.format(transactionProvider.balance),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: transactionProvider.balance < 0 ? Colors.red : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('총 수입', transactionProvider.totalIncome, Colors.green, formatter),
                _buildSummaryItem('총 지출', transactionProvider.totalExpenses, Colors.red, formatter),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color, NumberFormat formatter) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(
          formatter.format(amount),
          style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        if (transactionProvider.transactions.isEmpty) {
          return const Center(
            child: Text(
              '거래 내역이 없습니다.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          itemCount: transactionProvider.transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactionProvider.transactions[index];
            final formatter = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
            final date = DateFormat('yyyy.MM.dd').format(transaction.date);
            final color = transaction.type == 'income' ? Colors.green : Colors.red;
            final icon = transaction.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color, size: 30),
                ),
                title: Text(
                  transaction.category,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${date} - ${transaction.description ?? ''}',
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Text(
                  '${transaction.type == 'income' ? '+' : '-'}${formatter.format(transaction.amount)}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onTap: () => _showTransactionDialog(context, transaction.type, transaction: transaction),
              ),
            );
          },
        );
      },
    );
  }
}

void _showTransactionDialog(BuildContext context, String type, {txn.Transaction? transaction}) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return AddEditTransactionDialog(type: type, transaction: transaction);
    },
  );
}

class AddEditTransactionDialog extends StatefulWidget {
  final String type;
  final txn.Transaction? transaction;

  const AddEditTransactionDialog({super.key, required this.type, this.transaction});

  @override
  _AddEditTransactionDialogState createState() => _AddEditTransactionDialogState();
}

class _AddEditTransactionDialogState extends State<AddEditTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  late DateTime _selectedDate;

  final List<String> _expenseCategories = ['식비', '교통', '쇼핑', '문화/오락', '선물', '기타 지출'];
  final List<String> _incomeCategories = ['급여', '용돈', '기타 수입'];
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _categories = widget.type == 'income' ? _incomeCategories : _expenseCategories;

    _amountController = TextEditingController(text: widget.transaction?.amount.toStringAsFixed(0) ?? '');
    _descriptionController = TextEditingController(text: widget.transaction?.description ?? '');
    _selectedDate = widget.transaction?.date ?? DateTime.now();
    _selectedCategory = widget.transaction?.category ?? _categories.first;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final newTransaction = txn.Transaction(
        id: widget.transaction?.id,
        type: widget.type,
        category: _selectedCategory,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        description: _descriptionController.text,
      );

      final provider = Provider.of<TransactionProvider>(context, listen: false);
      if (widget.transaction == null) {
        provider.addTransaction(newTransaction);
      } else {
        provider.updateTransaction(newTransaction);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.transaction == null ? (widget.type == 'income' ? '수입 추가' : '지출 추가') : '거래 수정'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: '금액'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '금액을 입력하세요.';
                  }
                  if (double.tryParse(value) == null) {
                    return '숫자만 입력하세요.';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: '카테고리'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: '내용 (선택)'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Text(DateFormat('yyyy년 MM월 dd일').format(_selectedDate))),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('날짜 선택'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saveTransaction,
          child: const Text('저장'),
        ),
      ],
    );
  }
}
