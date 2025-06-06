import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddTransaction {
  final TransactionRepository repository;
  AddTransaction(this.repository);

  Future<void> call(String userId, Transaction transaction) {
    return repository.addTransaction(userId, transaction);
  }
}
