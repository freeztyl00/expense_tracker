import 'package:expense_tracker/presentation/providers/transaction_provider.dart';
import 'package:expense_tracker/domain/entities/transaction.dart' as domain;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditTransactionScreen extends StatefulWidget {
  final domain.TransactionExp transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _commentController;
  late DateTime selectedDate;
  late bool isExpense;
  late String selectedCategory;

  final List<String> expenseCategories = [
    'Їжа',
    'Транспорт',
    'Розваги',
    'Одяг',
    'Тварини',
    'Інше',
  ];
  final List<String> incomeCategories = ['Зарплата', 'Подарунок', 'Продаж'];

  List<String> get activeCategories =>
      isExpense ? expenseCategories : incomeCategories;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction.title);
    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    _commentController = TextEditingController(
      text: widget.transaction.comment ?? '',
    );
    selectedDate = widget.transaction.date;
    isExpense = widget.transaction.type == domain.TransactionType.expense;
    selectedCategory = widget.transaction.category;
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text);
    final comment = _commentController.text.trim();

    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заповніть назву і суму правильно.')),
      );
      return;
    }

    final provider = context.read<TransactionProvider>();
    final tx = domain.TransactionExp(
      id: widget.transaction.id,
      title: title,
      amount: amount,
      category: selectedCategory,
      type:
          isExpense
              ? domain.TransactionType.expense
              : domain.TransactionType.income,
      date: selectedDate,
      comment: comment.isEmpty ? null : comment,
    );

    try {
      await provider.updateTransaction(tx);
      Navigator.pop(context, tx);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Помилка при оновленні: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!activeCategories.contains(selectedCategory)) {
      selectedCategory = activeCategories.first;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Редагувати', style: const TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToggleButtons(
              isSelected: [isExpense, !isExpense],
              onPressed: (index) {
                setState(() {
                  isExpense = index == 0;
                  selectedCategory = activeCategories.first;
                });
              },
              borderRadius: BorderRadius.circular(12),
              selectedColor: Colors.white,
              fillColor: Colors.teal,
              color: Colors.teal,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Витрата'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Дохід'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Назва',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Сума (€)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: activeCategories.length,
                itemBuilder: (context, index) {
                  final cat = activeCategories[index];
                  final isSelected = cat == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => setState(() => selectedCategory = cat),
                      selectedColor: Colors.teal,
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Дата'),
                    Text(DateFormat('dd.MM.yyyy').format(selectedDate)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Коментар (необов’язково)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Зберегти'),
            ),
          ],
        ),
      ),
    );
  }
}
