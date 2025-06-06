import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Екран профілю користувача
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Вихід з акаунту
  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  // Побудова профілю
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профіль'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.person, size: 80, color: Colors.teal),
            const SizedBox(height: 20),
            Text('Email:', style: Theme.of(context).textTheme.titleMedium),
            Text(
              user?.email ?? 'Невідомо',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text('Ваш ID:', style: Theme.of(context).textTheme.titleMedium),
            Text(user?.uid ?? 'Невідомо', style: const TextStyle(fontSize: 18)),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout),
              label: const Text('Вийти з акаунту'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
