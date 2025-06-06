import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

// Оновлення існуючої транзакції
class UpdateTransaction {
  final TransactionRepository repository;
  UpdateTransaction(this.repository);

  // Запуск оновлення
  Future<void> call(String userId, Transaction transaction) {
    return repository.updateTransaction(userId, transaction);
  }
}
