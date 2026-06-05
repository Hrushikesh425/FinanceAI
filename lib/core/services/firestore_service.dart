import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/transaction.dart';
import '../models/portfolio_item.dart';

class FirestoreService {
  FirebaseFirestore? _db;

  FirestoreService() {
    try {
      _db = FirebaseFirestore.instance;
    } catch (e) {
      // Firebase not initialized yet
    }
  }

  // Generic helper for getting a user's document path
  String _userPath(String userId) => 'users/$userId';

  // --- Transactions ---

  Future<void> addTransaction(String userId, AppTransaction transaction) async {
    if (_db == null) return;
    await _db!
        .collection(_userPath(userId))
        .doc('data')
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toMap());
  }

  Stream<List<AppTransaction>> getTransactions(String userId) {
    if (_db == null) return Stream.value([]);
    return _db!
        .collection(_userPath(userId))
        .doc('data')
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppTransaction.fromMap(doc.data(), doc.id))
            .toList());
  }

  // --- Portfolio Items ---

  Future<void> addPortfolioItem(String userId, PortfolioItem item) async {
    if (_db == null) return;
    await _db!
        .collection(_userPath(userId))
        .doc('data')
        .collection('portfolio')
        .doc(item.id)
        .set(item.toMap());
  }

  Stream<List<PortfolioItem>> getPortfolioItems(String userId) {
    if (_db == null) return Stream.value([]);
    return _db!
        .collection(_userPath(userId))
        .doc('data')
        .collection('portfolio')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PortfolioItem.fromMap(doc.data(), doc.id))
            .toList());
  }
}
