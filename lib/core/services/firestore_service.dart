import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:finance_ai/core/models/transaction.dart';
import 'package:finance_ai/core/models/portfolio_item.dart';
import 'package:finance_ai/core/models/budget.dart';

class FirestoreService {
  FirebaseFirestore? _db;

  FirestoreService() {
    try {
      _db = FirebaseFirestore.instance;
      // Enable offline persistence
      _db!.settings = const Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
    } catch (e) {
      debugPrint('Firestore not available: $e');
    }
  }

  bool get isAvailable => _db != null;
  String _userPath(String uid) => 'users/$uid';

  // ─── TRANSACTIONS ────────────────────────────────────────────────────────────

  Future<void> addTransaction(String uid, AppTransaction tx) async {
    if (_db == null) return;
    await _db!.collection(_userPath(uid)).doc('data').collection('transactions').doc(tx.id).set(tx.toMap());
  }

  Future<void> updateTransaction(String uid, AppTransaction tx) async {
    if (_db == null) return;
    await _db!.collection(_userPath(uid)).doc('data').collection('transactions').doc(tx.id).update(tx.toMap());
  }

  Future<void> deleteTransaction(String uid, String txId) async {
    if (_db == null) return;
    await _db!.collection(_userPath(uid)).doc('data').collection('transactions').doc(txId).delete();
  }

  Stream<List<AppTransaction>> getTransactions(String uid) {
    if (_db == null) return Stream.value([]);
    return _db!.collection(_userPath(uid)).doc('data').collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => AppTransaction.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<AppTransaction>> getTransactionsByMonth(String uid, int year, int month) {
    if (_db == null) return Stream.value([]);
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 1).toIso8601String();
    return _db!.collection(_userPath(uid)).doc('data').collection('transactions')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => AppTransaction.fromMap(d.data(), d.id)).toList());
  }

  Future<List<AppTransaction>> getLastNTransactions(String uid, int n) async {
    if (_db == null) return [];
    final snap = await _db!.collection(_userPath(uid)).doc('data').collection('transactions')
        .orderBy('date', descending: true).limit(n).get();
    return snap.docs.map((d) => AppTransaction.fromMap(d.data(), d.id)).toList();
  }

  // ─── PORTFOLIO ───────────────────────────────────────────────────────────────

  Future<void> addPortfolioItem(String uid, PortfolioItem item) async {
    if (_db == null) return;
    await _db!.collection(_userPath(uid)).doc('data').collection('portfolio').doc(item.id).set(item.toMap());
  }

  Future<void> updatePortfolioItem(String uid, PortfolioItem item) async {
    if (_db == null) return;
    await _db!.collection(_userPath(uid)).doc('data').collection('portfolio').doc(item.id).update(item.toMap());
  }

  Future<void> deletePortfolioItem(String uid, String itemId) async {
    if (_db == null) return;
    await _db!.collection(_userPath(uid)).doc('data').collection('portfolio').doc(itemId).delete();
  }

  Stream<List<PortfolioItem>> getPortfolioItems(String uid) {
    if (_db == null) return Stream.value([]);
    return _db!.collection(_userPath(uid)).doc('data').collection('portfolio')
        .snapshots()
        .map((s) => s.docs.map((d) => PortfolioItem.fromMap(d.data(), d.id)).toList());
  }

  // ─── BUDGETS ─────────────────────────────────────────────────────────────────

  Future<void> saveBudget(String uid, Budget budget) async {
    if (_db == null) return;
    await _db!.collection(_userPath(uid)).doc('data').collection('budgets').doc(budget.category).set(budget.toMap());
  }

  Future<void> deleteBudget(String uid, String category) async {
    if (_db == null) return;
    await _db!.collection(_userPath(uid)).doc('data').collection('budgets').doc(category).delete();
  }

  Stream<List<Budget>> getBudgets(String uid) {
    if (_db == null) return Stream.value([]);
    return _db!.collection(_userPath(uid)).doc('data').collection('budgets')
        .snapshots()
        .map((s) => s.docs.map((d) => Budget.fromMap(d.data())).toList());
  }

  // ─── USER PROFILE ────────────────────────────────────────────────────────────

  Future<void> saveUserProfile(String uid, Map<String, dynamic> data) async {
    if (_db == null) return;
    await _db!.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    if (_db == null) return null;
    final doc = await _db!.collection('users').doc(uid).get();
    return doc.data();
  }
}
