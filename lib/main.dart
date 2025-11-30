import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for MethodChannel
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';

import 'package:home_widget/home_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'providers/transaction_provider.dart';
import 'models/transaction.dart' as txn;

// Android App Group ID
const String appGroupId = 'group.com.example.AccountMgmt';
// Method Channel for Deep Linking
const String deepLinkChannel = 'com.example.account_mgmt/deep_link';

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  // Set App Group ID for HomeWidget
  HomeWidget.setAppGroupId(appGroupId);
  
  runApp(const MyApp());

  // Setup MethodChannel after runApp
  const MethodChannel channel = MethodChannel(deepLinkChannel);
  channel.setMethodCallHandler((call) async {
    if (call.method == 'open_add_expense_screen') {
      // Use the navigatorKey to show the dialog
      // Ensure the context is not null before using it.
      final context = navigatorKey.currentContext;
      if (context != null) {
        _showTransactionDialog(context, 'expense');
      }
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: MaterialApp(
        navigatorKey: navigatorKey, // Assign the navigatorKey
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isCalendarView = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateWidget();
    Provider.of<TransactionProvider>(context).addListener(_updateWidget);
  }

  @override
  void dispose() {
    Provider.of<TransactionProvider>(context, listen: false).removeListener(_updateWidget);
    super.dispose();
  }

  void _updateWidget() {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final formatter = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    final balance = formatter.format(transactionProvider.balance);

    HomeWidget.saveWidgetData<String>('current_balance', balance);
    HomeWidget.updateWidget(
      name: 'AppWidgetProvider',
      androidName: 'AppWidgetProvider',
    );
  }

  List<txn.Transaction> _getEventsForDay(DateTime day) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    return provider.transactions.where((transaction) => isSameDay(transaction.date, day)).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 용돈 관리'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_today),
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SummaryCard(),
          if (_isCalendarView)
            Expanded(
              child: TransactionCalendar(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                onDaySelected: _onDaySelected,
                getEventsForDay: _getEventsForDay,
              ),
            )
          else
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

class TransactionCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final List<txn.Transaction> Function(DateTime) getEventsForDay;

  const TransactionCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.getEventsForDay,
  });

  @override
  Widget build(BuildContext context) {
    final selectedDayEvents = selectedDay != null ? getEventsForDay(selectedDay!) : [];
    double dailyIncome = 0;
    double dailyExpense = 0;
    for (var event in selectedDayEvents) {
      if (event.type == 'income') {
        dailyIncome += event.amount;
      } else {
        dailyExpense += event.amount;
      }
    }
    double dailyNet = dailyIncome - dailyExpense;
    final formatter = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');

    return Column(
      children: [
        TableCalendar(
          locale: 'ko_KR',
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          onDaySelected: onDaySelected,
          eventLoader: getEventsForDay,
          calendarStyle: const CalendarStyle(
            markerDecoration: BoxDecoration(
              color: Colors.deepPurpleAccent,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
        const SizedBox(height: 8.0),
        if (selectedDay != null)
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                            _buildDailySummaryItem('수입', dailyIncome, Colors.green, formatter),
                            _buildDailySummaryItem('지출', dailyExpense, Colors.red, formatter),
                            _buildDailySummaryItem('합계', dailyNet, dailyNet >= 0 ? Colors.blue : Colors.red, formatter),
                        ],
                    ),
                ),
            ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: selectedDayEvents.length,
            itemBuilder: (context, index) {
              final event = selectedDayEvents[index];
              final color = event.type == 'income' ? Colors.green : Colors.red;
              final icon = event.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward;

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
                    event.category,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    event.description ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Text(
                    '${event.type == 'income' ? '+' : '-'}${formatter.format(event.amount)}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () => _showTransactionDialog(context, event.type, transaction: event),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailySummaryItem(String title, double amount, Color color, NumberFormat formatter) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(
          formatter.format(amount),
          style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold),
        ),
      ],
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
      lastDate: DateTime(2101),
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

  void _deleteTransaction() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('거래내역 삭제'),
        content: const Text('정말로 이 거래내역을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: const Text('삭제'),
            onPressed: () {
              Provider.of<TransactionProvider>(context, listen: false)
                  .deleteTransaction(widget.transaction!.id!);
              Navigator.of(ctx).pop(); // Close the confirmation dialog
              Navigator.of(context).pop(); // Close the edit dialog
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.transaction == null ? (widget.type == 'income' ? '수입 추가' : '지출 추가') : '거래 수정'),
      content: Form(
        key: _formKey,
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
      actions: <Widget>[
        if (widget.transaction != null)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteTransaction,
          ),
        const Spacer(),
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