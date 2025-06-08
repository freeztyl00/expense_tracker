import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../presentation/screens/login_screens.dart';
import 'biometric_auth_screen.dart';
import 'package:provider/provider.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/login_screens.dart';
import '../../presentation/screens/setup_screen.dart';
import '../providers/transaction_provider.dart';

// Віджет, що перевіряє стан автентифікації користувача
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Показуємо індикатор, поки перевіряємо стан користувача
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          // Якщо користувач не залогінений, показуємо екран входу
          return const LoginScreen();
        }

        // Якщо користувач залогінений, просимо підтвердити вхід біометрією
        return const BiometricAuthScreen();
        
        final provider = Provider.of<TransactionProvider>(context, listen: false);
        provider.updateUser(user.uid);
        return FutureBuilder(
          future: provider.loadData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Завантаження даних користувача
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            // Якщо баланс ще не встановлено - показуємо екран налаштування
            if (provider.initialBalance == null) {
              return const SetupScreen();
            }
            // Інакше переходимо на головний екран
            return const HomeScreen();
          },
        );
      },
    );
  }
}
