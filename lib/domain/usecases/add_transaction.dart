import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

// Юзкейс для додавання нової транзакції
class AddTransaction {
  final TransactionRepository repository;
  AddTransaction(this.repository);

  Future<void> call(String userId, TransactionExp transaction) {
    return repository.addTransaction(userId, transaction);
  }
}
