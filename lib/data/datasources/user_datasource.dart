import 'package:cloud_firestore/cloud_firestore.dart';

// Джерело даних користувача у Firestore
class UserDatasource {
  final FirebaseFirestore firestore;
  UserDatasource(this.firestore);

  // Повертає документ користувача
  DocumentReference<Map<String, dynamic>> _userDoc(String userId) {
    return firestore.collection('users').doc(userId);
  }

  // Отримати початковий баланс, якщо він існує
  Future<double?> getInitialBalance(String userId) async {
    final doc = await _userDoc(userId).get();
    if (doc.exists && doc.data()!.containsKey('initialBalance')) {
      return (doc.data()!['initialBalance'] as num).toDouble();
    }
    return null;
  }

  // Встановити початковий баланс
  Future<void> setInitialBalance(String userId, double balance) {
    return _userDoc(userId).set({'initialBalance': balance});
  }
}
