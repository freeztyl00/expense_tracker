import 'package:expense_tracker/presentation/screens/add_transaction_screen.dart';
import 'package:expense_tracker/presentation/screens/edit_transaction_screen.dart';
import 'package:expense_tracker/presentation/screens/home_screen.dart';
import 'package:expense_tracker/presentation/screens/login_screens.dart';
import 'package:expense_tracker/presentation/screens/profile_screen.dart';
import 'package:expense_tracker/presentation/providers/transaction_provider.dart';
import 'package:expense_tracker/data/repositories/firestore_transaction_repository.dart';
import 'package:expense_tracker/domain/usecases/add_transaction.dart';
import 'package:expense_tracker/domain/usecases/delete_transaction.dart';
import 'package:expense_tracker/domain/usecases/get_initial_balance.dart';
import 'package:expense_tracker/domain/usecases/get_transactions.dart';
import 'package:expense_tracker/domain/usecases/set_initial_balance.dart';
import 'package:expense_tracker/domain/usecases/update_transaction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:expense_tracker/presentation/screens/setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = FirestoreTransactionRepository();
    return ChangeNotifierProvider(
      create: (_) => TransactionProvider(
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        getTransactionsUseCase: GetTransactions(repository),
        addTransactionUseCase: AddTransaction(repository),
        updateTransactionUseCase: UpdateTransaction(repository),
        deleteTransactionUseCase: DeleteTransaction(repository),
        getInitialBalanceUseCase: GetInitialBalance(repository),
        setInitialBalanceUseCase: SetInitialBalance(repository),
      ),
      child: MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/setup': (context) => const SetupScreen(),
        '/home': (context) => const HomeScreen(),
        '/add': (context) => const AddTransactionScreen(),
        '/edit': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return EditTransactionScreen(transaction: args);
        },
        '/profile': (context) => const ProfileScreen(),
      },
    ),
    );
  }
}
