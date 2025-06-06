enum TransactionType { expense, income }

class TransactionExp {
  final String id;
  final String title;
  final double amount;
  final String category;
  final TransactionType type;
  final DateTime date;
  final String? comment;

  TransactionExp({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.comment,
  });
}
