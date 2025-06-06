import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

// Отримати список транзакцій користувача
class GetTransactions {
  final TransactionRepository repository;
  GetTransactions(this.repository);

  Future<List<TransactionExp>> call(String userId) {
    return repository.getTransactions(userId);
  }
}
