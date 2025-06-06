import '../repositories/transaction_repository.dart';

// Зберегти стартовий баланс користувача
class SetInitialBalance {
  final TransactionRepository repository;
  SetInitialBalance(this.repository);

  // Записуємо нове значення балансу
  Future<void> call(String userId, double balance) {
    return repository.setInitialBalance(userId, balance);
  }
}
