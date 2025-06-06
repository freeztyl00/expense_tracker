import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/presentation/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

// Екран встановлення початкового балансу
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  // Контролер вводу балансу
  final _balanceController = TextEditingController();
  String? _error;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _checkIfUserHasBalance();
  }

  // Перевіряємо, чи вже заданий баланс
  Future<void> _checkIfUserHasBalance() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    provider.updateUser(userId);
    await provider.loadData();
    if (provider.initialBalance != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // Зберігаємо введений баланс
  Future<void> _saveBalance() async {
    final balanceText = _balanceController.text.trim();
    final balance = double.tryParse(balanceText);

    if (balance == null || balance < 0) {
      setState(() => _error = 'Введіть коректну суму');
      return;
    }

    try {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      provider.updateUser(userId);
      await provider.setInitialBalance(balance);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _error = 'Сталася помилка при збереженні: $e';
      });
    }
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  @override
  // Побудова форми введення балансу
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Початковий баланс'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            TextField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Введіть початковий баланс (євро)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveBalance,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Продовжити', style: TextStyle(fontSize: 16)),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
