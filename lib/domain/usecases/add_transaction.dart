import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

// Юзкейс для додавання нової транзакції
class AddTransaction {
  // Репозиторій передається через конструктор
  final TransactionRepository repository;
  AddTransaction(this.repository);

  // Виконання юзкейсу
  Future<void> call(String userId, Transaction transaction) {
    return repository.addTransaction(userId, transaction);
  }
}
