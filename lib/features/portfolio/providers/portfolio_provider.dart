import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_ai/core/models/portfolio_item.dart';
import 'package:finance_ai/features/auth/providers/auth_provider.dart';
import 'package:finance_ai/features/home/providers/transaction_provider.dart';

final portfolioProvider = StreamProvider<List<PortfolioItem>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.getPortfolioItems(user.uid);
});

final addPortfolioItemProvider = Provider((ref) {
  return (PortfolioItem item) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) throw Exception('User not logged in');
    
    final firestore = ref.read(firestoreServiceProvider);
    await firestore.addPortfolioItem(user.uid, item);
  };
});
