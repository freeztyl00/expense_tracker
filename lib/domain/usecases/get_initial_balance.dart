import '../repositories/transaction_repository.dart';

class GetInitialBalance {
  final TransactionRepository repository;
  GetInitialBalance(this.repository);

  Future<double?> call(String userId) {
    return repository.getInitialBalance(userId);
  }
}
