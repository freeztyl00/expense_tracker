import '../repositories/transaction_repository.dart';

// Юзкейс для видалення транзакції
class DeleteTransaction {
  final TransactionRepository repository;
  DeleteTransaction(this.repository);

  // Запуск видалення
  Future<void> call(String userId, String id) {
    return repository.deleteTransaction(userId, id);
  }
}
