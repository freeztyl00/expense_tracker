import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions(String userId);
  Future<void> addTransaction(String userId, Transaction transaction);
  Future<void> updateTransaction(String userId, Transaction transaction);
  Future<void> deleteTransaction(String userId, String id);
  Future<double?> getInitialBalance(String userId);
  Future<void> setInitialBalance(String userId, double balance);
}
