import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/transaction.dart';
import '../auth/providers/auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final transactionsProvider = StreamProvider<List<AppTransaction>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value([]);
  }
  
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getTransactions(user.uid);
});

// A provider to add a transaction easily
final addTransactionProvider = Provider((ref) {
  return (AppTransaction transaction) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    
    final firestoreService = ref.read(firestoreServiceProvider);
    await firestoreService.addTransaction(user.uid, transaction);
  };
});
