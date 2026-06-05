import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/portfolio_item.dart';
import '../home/providers/transaction_provider.dart'; // To get firestoreServiceProvider
import '../auth/providers/auth_provider.dart';

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
