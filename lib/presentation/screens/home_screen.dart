import 'package:expense_tracker/utils/category_colors.dart';
import 'package:expense_tracker/presentation/providers/transaction_provider.dart';
import 'package:expense_tracker/domain/entities/transaction.dart' as domain;
import 'package:expense_tracker/utils/category_icons.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'transactions_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isExpense = true;
  DateTimeRange selectedRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    provider.updateUser(FirebaseAuth.instance.currentUser!.uid);
    provider.loadData();
  }

  List<domain.TransactionExp> get transactions =>
      context.watch<TransactionProvider>().transactions;

  double get initialBalance =>
      context.watch<TransactionProvider>().initialBalance ?? 0;

  List<domain.TransactionExp> get filteredTransactions {
    return transactions.where((t) {
      final date = t.date;
      final typeMatch =
          t.type ==
          (isExpense
              ? domain.TransactionType.expense
              : domain.TransactionType.income);
      return typeMatch &&
          date.isAfter(selectedRange.start.subtract(const Duration(days: 1))) &&
          date.isBefore(selectedRange.end.add(const Duration(days: 1)));
    }).toList();
  }

  double get totalAmount =>
      filteredTransactions.fold(0.0, (sum, t) => sum + t.amount);

  double get calculatedBalance {
    double expenses = transactions
        .where((t) => t.type == domain.TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    double incomes = transactions
        .where((t) => t.type == domain.TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    return initialBalance + incomes - expenses;
  }

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (var t in filteredTransactions) {
      final cat = t.category;
      final amt = t.amount;
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
                    await Provider.of<TransactionProvider>(
                      context,
                      listen: false,
                    ).loadData();
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
                                                        t.category == entry.key,
                                                  )
                                                  .toList(),
                                        ),
                                  ),
                                );
                                await Provider.of<TransactionProvider>(
                                  context,
                                  listen: false,
                                ).loadData();
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
