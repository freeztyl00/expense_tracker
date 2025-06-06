import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_datasource.dart';
import '../datasources/user_datasource.dart';

class FirestoreTransactionRepository implements TransactionRepository {
  final TransactionDatasource transactionDatasource;
  final UserDatasource userDatasource;

  FirestoreTransactionRepository({FirebaseFirestore? firestore})
    : transactionDatasource = TransactionDatasource(
        firestore ?? FirebaseFirestore.instance,
      ),
      userDatasource = UserDatasource(firestore ?? FirebaseFirestore.instance);

  @override
  Future<void> addTransaction(String userId, TransactionExp transaction) {
    return transactionDatasource.add(userId, transaction);
  }

  @override
  Future<void> deleteTransaction(String userId, String id) {
    return transactionDatasource.delete(userId, id);
  }

  @override
  Future<List<TransactionExp>> getTransactions(String userId) {
    return transactionDatasource.fetchTransactions(userId);
  }

  @override
  Future<void> updateTransaction(String userId, TransactionExp transaction) {
    return transactionDatasource.update(userId, transaction);
  }

  @override
  Future<double?> getInitialBalance(String userId) {
    return userDatasource.getInitialBalance(userId);
  }

  @override
  Future<void> setInitialBalance(String userId, double balance) {
    return userDatasource.setInitialBalance(userId, balance);
  }
}
