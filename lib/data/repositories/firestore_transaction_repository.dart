import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_datasource.dart';
import '../datasources/user_datasource.dart';

// Реалізація репозиторію поверх Firestore
class FirestoreTransactionRepository implements TransactionRepository {
  final TransactionDatasource transactionDatasource;
  final UserDatasource userDatasource;

  // Ініціалізуємо джерела даних з переданого або стандартного Firestore
  FirestoreTransactionRepository({FirebaseFirestore? firestore})
      : transactionDatasource =
            TransactionDatasource(firestore ?? FirebaseFirestore.instance),
        userDatasource = UserDatasource(firestore ?? FirebaseFirestore.instance);

  @override
  Future<void> addTransaction(String userId, Transaction transaction) {
    return transactionDatasource.add(userId, transaction); // делегуємо в datasource
  }

  @override
  Future<void> deleteTransaction(String userId, String id) {
    return transactionDatasource.delete(userId, id); // видалення в datasource
  }

  @override
  Future<List<Transaction>> getTransactions(String userId) {
    return transactionDatasource.fetchTransactions(userId); // отримання списку
  }

  @override
  Future<void> updateTransaction(String userId, Transaction transaction) {
    return transactionDatasource.update(userId, transaction); // оновлення
  }

  @override
  Future<double?> getInitialBalance(String userId) {
    return userDatasource.getInitialBalance(userId); // отримуємо баланс
  }

  @override
  Future<void> setInitialBalance(String userId, double balance) {
    return userDatasource.setInitialBalance(userId, balance); // записуємо баланс
  }
}
