import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactions {
  final TransactionRepository repository;
  GetTransactions(this.repository);

  Future<List<TransactionExp>> call(String userId) {
    return repository.getTransactions(userId);
  }
}
