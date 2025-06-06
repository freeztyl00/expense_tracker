import 'package:flutter/foundation.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_initial_balance.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/set_initial_balance.dart';
import '../../domain/usecases/update_transaction.dart';

class TransactionProvider with ChangeNotifier {
  String userId;
  final GetTransactions getTransactionsUseCase;
  final AddTransaction addTransactionUseCase;
  final UpdateTransaction updateTransactionUseCase;
  final DeleteTransaction deleteTransactionUseCase;
  final GetInitialBalance getInitialBalanceUseCase;
  final SetInitialBalance setInitialBalanceUseCase;

  List<Transaction> transactions = [];
  double? initialBalance;

  TransactionProvider({
    required this.userId,
    required this.getTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
    required this.getInitialBalanceUseCase,
    required this.setInitialBalanceUseCase,
  });

  void updateUser(String id) {
    userId = id;
  }

  Future<void> loadData() async {
    final results = await Future.wait([
      getTransactionsUseCase(userId),
      getInitialBalanceUseCase(userId),
    ]);
    transactions = results[0] as List<Transaction>;
    initialBalance = results[1] as double?;
    notifyListeners();
  }

  Future<void> addTransaction(Transaction tx) async {
    await addTransactionUseCase(userId, tx);
    await loadData();
  }

  Future<void> updateTransaction(Transaction tx) async {
    await updateTransactionUseCase(userId, tx);
    await loadData();
  }

  Future<void> deleteTransaction(String id) async {
    await deleteTransactionUseCase(userId, id);
    await loadData();
  }

  Future<void> setInitialBalance(double balance) async {
    await setInitialBalanceUseCase(userId, balance);
    await loadData();
  }
}
