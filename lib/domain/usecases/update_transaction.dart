import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

// Оновлення існуючої транзакції
class UpdateTransaction {
  final TransactionRepository repository;
  UpdateTransaction(this.repository);

  Future<void> call(String userId, TransactionExp transaction) {
    return repository.updateTransaction(userId, transaction);
  }
}
