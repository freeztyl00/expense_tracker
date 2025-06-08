import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import 'home_screen.dart';
import 'setup_screen.dart';

// Екран біометричної авторизації
class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  final _auth = LocalAuthentication();
  bool _isChecking = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  // Перевіряємо відбиток пальця та переходимо до додатку
  Future<void> _authenticate() async {
    try {
      final canCheck = await _auth.canCheckBiometrics ||
          await _auth.isDeviceSupported();
      bool success = false;
      if (canCheck) {
        success = await _auth.authenticate(
          localizedReason: 'Підтвердіть вхід відбитком пальця',
          options: const AuthenticationOptions(biometricOnly: true),
        );
      } else {
        setState(() {
          _error = 'Біометрія недоступна на пристрої';
        });
      }
      if (success) {
        final user = FirebaseAuth.instance.currentUser!;
        final provider = Provider.of<TransactionProvider>(context, listen: false);
        provider.updateUser(user.uid);
        await provider.loadData();
        if (provider.initialBalance == null) {
          Navigator.pushReplacementNamed(context, '/setup');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      setState(() => _error = 'Помилка біометричної авторизації: $e');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isChecking = true;
                  _error = null;
                });
                _authenticate();
              },
              icon: const Icon(Icons.fingerprint),
              label: const Text('Увійти'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
