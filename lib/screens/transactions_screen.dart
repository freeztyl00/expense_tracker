import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/utils/category_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'transaction_detail_screen.dart';
import '../utils/category_icons.dart';

class TransactionsScreen extends StatefulWidget {
  final String category;
  final String type; // 'expense' або 'income'
  final List<Map<String, dynamic>> transactions;

  const TransactionsScreen({
    super.key,
    required this.category,
    required this.type,
    required this.transactions,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late List<Map<String, dynamic>> localTransactions;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    localTransactions = List<Map<String, dynamic>>.from(widget.transactions);
  }

  Future<void> _openTransactionDetail(Map<String, dynamic> tx) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => TransactionDetailScreen(
              transaction: tx,
              onEdit: (updatedTx) {
                setState(() {
                  final index = localTransactions.indexWhere(
                    (e) => e['id'] == updatedTx['id'],
                  );
                  if (index != -1) localTransactions[index] = updatedTx;
                });
              },
              onDelete: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('transactions')
                      .doc(tx['id'])
                      .delete();

                  Navigator.pop(context, 'deleted');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Помилка при видаленні: $e')),
                  );
                }
              },
            ),
      ),
    );

    if (result == 'deleted') {
      setState(() {
        localTransactions.removeWhere((t) => t['id'] == tx['id']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var tx in localTransactions) {
      final dateStr = DateFormat('dd.MM.yyyy').format(tx['date'] as DateTime);
      grouped.putIfAbsent(dateStr, () => []).add(tx);
    }

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body:
          localTransactions.isEmpty
              ? const Center(
                child: Text(
                  'Немає транзакцій у цій категорії',
                  style: TextStyle(color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  final date = sortedDates[index];
                  final txs = grouped[date]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...txs.map((tx) {
                        final amount = (tx['amount'] as double).toStringAsFixed(
                          2,
                        );
                        final color =
                            widget.type == 'expense'
                                ? Colors.red
                                : Colors.green;
                        final comment = (tx['comment'] ?? '').toString();

                        return GestureDetector(
                          onTap: () => _openTransactionDetail(tx),
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: getCategoryColor(
                                      tx['category'],
                                    ),
                                    child: Icon(
                                      categoryIcons[tx['category']] ??
                                          Icons.category,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                tx['title'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              '€$amount',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: color,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (comment.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: FractionallySizedBox(
                                              widthFactor: 0.75,
                                              child: Text(
                                                comment,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
    );
  }
}
