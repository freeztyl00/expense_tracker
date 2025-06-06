import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransaction {
  final TransactionRepository repository;
  UpdateTransaction(this.repository);

  Future<void> call(String userId, Transaction transaction) {
    return repository.updateTransaction(userId, transaction);
  }
}
