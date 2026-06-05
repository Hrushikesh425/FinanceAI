import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_ai/core/models/portfolio_item.dart';
import 'package:finance_ai/features/home/providers/transaction_provider.dart'; // To get firestoreServiceProvider
import 'package:finance_ai/features/auth/providers/auth_provider.dart';

final portfolioProvider = StreamProvider<List<PortfolioItem>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value([]);
  }
  
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getPortfolioItems(user.uid);
});

final addPortfolioItemProvider = Provider((ref) {
  return (PortfolioItem item) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    
    final firestoreService = ref.read(firestoreServiceProvider);
    await firestoreService.addPortfolioItem(user.uid, item);
  };
});
