import 'package:flutter/foundation.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_initial_balance.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/set_initial_balance.dart';
import '../../domain/usecases/update_transaction.dart';

// Провайдер стану, який використовує юзкейси
class TransactionProvider with ChangeNotifier {
  String userId;
  final GetTransactions getTransactionsUseCase;
  final AddTransaction addTransactionUseCase;
  final UpdateTransaction updateTransactionUseCase;
  final DeleteTransaction deleteTransactionUseCase;
  final GetInitialBalance getInitialBalanceUseCase;
  final SetInitialBalance setInitialBalanceUseCase;

  List<TransactionExp> transactions = [];
  double? initialBalance;

  // Всі залежності передаються через конструктор
  TransactionProvider({
    required this.userId,
    required this.getTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
    required this.getInitialBalanceUseCase,
    required this.setInitialBalanceUseCase,
  });

  //Для зміни поточного користувача
  void updateUser(String id) {
    userId = id;
  }

  // Завантажуємо транзакції та баланс паралельно
  Future<void> loadData() async {
    final results = await Future.wait([
      getTransactionsUseCase(userId),
      getInitialBalanceUseCase(userId),
    ]);
    transactions = results[0] as List<TransactionExp>;
    initialBalance = results[1] as double?;
    notifyListeners();
  }

  // Додати нову транзакцію і оновити список
  Future<void> addTransaction(TransactionExp tx) async {
    await addTransactionUseCase(userId, tx);
    await loadData();
  }

  // Оновити транзакцію
  Future<void> updateTransaction(TransactionExp tx) async {
    await updateTransactionUseCase(userId, tx);
    await loadData();
  }

  // Видалити транзакцію
  Future<void> deleteTransaction(String id) async {
    await deleteTransactionUseCase(userId, id);
    await loadData();
  }

  // Зберегти початковий баланс
  Future<void> setInitialBalance(double balance) async {
    await setInitialBalanceUseCase(userId, balance);
    await loadData();
  }
}
