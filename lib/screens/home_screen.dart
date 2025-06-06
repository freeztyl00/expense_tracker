import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/utils/category_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'transactions_screen.dart';
import '../utils/category_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  bool isExpense = true;
  DateTimeRange selectedRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );

  List<Map<String, dynamic>> transactions = [];
  double initialBalance = 0;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    await Future.wait([_loadUserData(), _loadTransactions()]);
  }

  Future<void> _loadUserData() async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists && doc.data()?['initialBalance'] != null) {
      setState(() {
        initialBalance = (doc.data()!['initialBalance'] as num).toDouble();
      });
    }
  }

  Future<void> _loadTransactions() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .get();

    final fetched =
        snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            ...data,
            'id': doc.id,
            'date': (data['date'] as Timestamp).toDate(),
          };
        }).toList();

    setState(() {
      transactions = fetched;
    });
  }

  List<Map<String, dynamic>> get filteredTransactions {
    return transactions.where((t) {
      final date = t['date'] as DateTime;
      return t['type'] == (isExpense ? 'expense' : 'income') &&
          date.isAfter(selectedRange.start.subtract(const Duration(days: 1))) &&
          date.isBefore(selectedRange.end.add(const Duration(days: 1)));
    }).toList();
  }

  double get totalAmount =>
      filteredTransactions.fold(0.0, (sum, t) => sum + (t['amount'] as double));

  double get calculatedBalance {
    double expenses = transactions
        .where((t) => t['type'] == 'expense')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));
    double incomes = transactions
        .where((t) => t['type'] == 'income')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));
    return initialBalance + incomes - expenses;
  }

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (var t in filteredTransactions) {
      final cat = t['category'] as String;
      final amt = t['amount'] as double;
      totals[cat] = (totals[cat] ?? 0) + amt;
    }
    return totals;
  }

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final userName = userEmail.split('@').first;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Padding(
          padding: EdgeInsets.only(left: 8, top: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.person, color: Colors.black),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Привіт, $userName!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            _buildBalanceCard(),
            const SizedBox(height: 20),
            _buildToggleButtons(),
            const SizedBox(height: 20),
            _buildDateSelector(),
            const SizedBox(height: 24),
            Expanded(child: _buildChartAndList()),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Баланс',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            '€${calculatedBalance.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Center(
      child: ToggleButtons(
        isSelected: [isExpense, !isExpense],
        onPressed: (index) => setState(() => isExpense = index == 0),
        borderRadius: BorderRadius.circular(12),
        selectedColor: Colors.white,
        fillColor: Colors.teal,
        color: Colors.teal,
        constraints: const BoxConstraints(minHeight: 40, minWidth: 120),
        children: const [Text('Витрати'), Text('Доходи')],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Center(
      child: GestureDetector(
        onTap: _pickDateRange,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('dd.MM').format(selectedRange.start)} - ${DateFormat('dd.MM').format(selectedRange.end)}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartAndList() {
    final showPlaceholder = categoryTotals.isEmpty;

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sections:
                      showPlaceholder
                          ? [
                            PieChartSectionData(
                              value: 1,
                              title: '',
                              color: Colors.grey.shade300,
                              radius: 50,
                            ),
                          ]
                          : categoryTotals.entries.map((entry) {
                            final percent = (entry.value / totalAmount) * 100;
                            return PieChartSectionData(
                              value: entry.value,
                              title: '${percent.toStringAsFixed(1)}%',
                              color: getCategoryColor(entry.key),
                              radius: 50,
                            );
                          }).toList(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
              Center(
                child: FloatingActionButton(
                  backgroundColor: Colors.green[700],
                  shape: const CircleBorder(),
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/add');
                    await _fetchAll(); // Перезавантажити все
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '€${totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Expanded(
          child:
              showPlaceholder
                  ? const Center(
                    child: Text('Немає транзакцій за даний період'),
                  )
                  : ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children:
                        categoryTotals.entries.map((entry) {
                          final percent = (entry.value / totalAmount) * 100;
                          final amountColor =
                              isExpense ? Colors.red : Colors.green;

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: getCategoryColor(entry.key),
                                child: Icon(
                                  categoryIcons[entry.key] ?? Icons.category,
                                  color: Colors.white,
                                ),
                              ),

                              title: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text('${percent.toStringAsFixed(1)}%'),
                              trailing: Text(
                                '€${entry.value.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: amountColor,
                                ),
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => TransactionsScreen(
                                          category: entry.key,
                                          type:
                                              isExpense ? 'expense' : 'income',
                                          transactions:
                                              filteredTransactions
                                                  .where(
                                                    (t) =>
                                                        t['category'] ==
                                                        entry.key,
                                                  )
                                                  .toList(),
                                        ),
                                  ),
                                );
                                await _fetchAll(); // оновлення після повернення
                              },
                            ),
                          );
                        }).toList(),
                  ),
        ),
      ],
    );
  }
}
