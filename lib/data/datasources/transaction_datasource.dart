import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction.dart' as domain;

class TransactionDatasource {
  final FirebaseFirestore firestore;
  TransactionDatasource(this.firestore);

  CollectionReference<Map<String, dynamic>> _txCollection(String userId) {
    return firestore.collection('users').doc(userId).collection('transactions');
  }

  Future<List<domain.Transaction>> fetchTransactions(String userId) async {
    final snapshot = await _txCollection(userId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return domain.Transaction(
        id: doc.id,
        title: data['title'] ?? '',
        amount: (data['amount'] as num).toDouble(),
        category: data['category'] ?? '',
        type: data['type'] == 'income'
            ? domain.TransactionType.income
            : domain.TransactionType.expense,
        date: (data['date'] as Timestamp).toDate(),
        comment: data['comment'],
      );
    }).toList();
  }

  Future<void> add(String userId, domain.Transaction tx) {
    return _txCollection(userId).add({
      'title': tx.title,
      'amount': tx.amount,
      'category': tx.category,
      'type': tx.type == domain.TransactionType.income ? 'income' : 'expense',
      'date': Timestamp.fromDate(tx.date),
      'comment': tx.comment,
    });
  }

  Future<void> update(String userId, domain.Transaction tx) {
    return _txCollection(userId).doc(tx.id).update({
      'title': tx.title,
      'amount': tx.amount,
      'category': tx.category,
      'type': tx.type == domain.TransactionType.income ? 'income' : 'expense',
      'date': Timestamp.fromDate(tx.date),
      'comment': tx.comment,
    });
  }

  Future<void> delete(String userId, String id) {
    return _txCollection(userId).doc(id).delete();
  }
}
