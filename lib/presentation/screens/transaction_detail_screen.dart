import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'edit_transaction_screen.dart';
import 'package:expense_tracker/domain/entities/transaction.dart' as domain;

// Екран перегляду однієї транзакції
class TransactionDetailScreen extends StatefulWidget {
  final domain.TransactionExp transaction;
  final void Function(domain.TransactionExp) onEdit;
  final VoidCallback onDelete;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  // Поточна транзакція, яка може оновлюватись
  late domain.TransactionExp currentTransaction;

  @override
  void initState() {
    super.initState();
    currentTransaction = widget.transaction;
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = currentTransaction.type == domain.TransactionType.expense;
    final amount = currentTransaction.amount.toStringAsFixed(2);
    final color = isExpense ? Colors.red : Colors.green;
    final date = DateFormat('dd.MM.yyyy').format(currentTransaction.date);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text(
          'Деталі транзакції',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('Назва:', currentTransaction.title),
            const SizedBox(height: 16),
            _buildRow('Сума:', '€$amount', valueColor: color),
            const SizedBox(height: 16),
            _buildRow('Категорія:', currentTransaction.category),
            const SizedBox(height: 16),
            _buildRow('Тип:', isExpense ? 'Витрата' : 'Дохід'),
            const SizedBox(height: 16),
            _buildRow('Дата:', date),
            const SizedBox(height: 16),
            if ((currentTransaction.comment ?? '').isNotEmpty)
              _buildRow('Коментар:', currentTransaction.comment ?? ''),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Видалити',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => EditTransactionScreen(
                                transaction: currentTransaction,
                              ),
                        ),
                      );
                      if (result != null && result is domain.TransactionExp) {
                        setState(() => currentTransaction = result);
                        widget.onEdit(result);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Редагувати',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return RichText(
      text: TextSpan(
        text: '$label\n',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: valueColor ?? Colors.black,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
