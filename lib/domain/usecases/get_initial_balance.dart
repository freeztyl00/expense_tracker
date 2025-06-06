import '../repositories/transaction_repository.dart';

// Отримання початкового балансу користувача
class GetInitialBalance {
  final TransactionRepository repository;
  GetInitialBalance(this.repository);

  // Повертає balance або null
  Future<double?> call(String userId) {
    return repository.getInitialBalance(userId);
  }
}
