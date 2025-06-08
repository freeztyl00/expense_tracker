import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../presentation/screens/login_screens.dart';
import 'biometric_auth_screen.dart';

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
      },
    );
  }
}
