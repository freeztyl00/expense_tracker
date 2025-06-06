import '../repositories/transaction_repository.dart';

class SetInitialBalance {
  final TransactionRepository repository;
  SetInitialBalance(this.repository);

  Future<void> call(String userId, double balance) {
    return repository.setInitialBalance(userId, balance);
  }
}
