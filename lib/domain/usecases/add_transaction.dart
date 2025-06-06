import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddTransaction {
  final TransactionRepository repository;
  AddTransaction(this.repository);

  Future<void> call(String userId, TransactionExp transaction) {
    return repository.addTransaction(userId, transaction);
  }
}
