import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_ai/core/models/transaction.dart';
import 'package:finance_ai/core/models/budget.dart';
import 'package:finance_ai/core/services/gemini_service.dart';
import 'package:finance_ai/features/home/providers/transaction_provider.dart';
import 'package:finance_ai/features/auth/providers/auth_provider.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

// ─── MONTHLY COMPUTED STATS ──────────────────────────────────────────────────

class MonthlyStats {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final double savingsRate;
  final Map<String, double> categorySpending;
  final List<String> topCategories;

  MonthlyStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.savingsRate,
    required this.categorySpending,
    required this.topCategories,
  });

  factory MonthlyStats.empty() => MonthlyStats(
    totalIncome: 0, totalExpense: 0, balance: 0, savingsRate: 0,
    categorySpending: {}, topCategories: [],
  );

  factory MonthlyStats.fromTransactions(List<AppTransaction> transactions) {
    double income = 0, expense = 0;
    final Map<String, double> spending = {};

    for (final tx in transactions) {
      if (tx.type == TransactionType.income) {
        income += tx.amount.abs();
      } else {
        expense += tx.amount.abs();
        spending[tx.category] = (spending[tx.category] ?? 0) + tx.amount.abs();
      }
    }

    final savingsRate = income > 0 ? ((income - expense) / income * 100).clamp(0.0, 100.0) : 0.0;
    final sorted = spending.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return MonthlyStats(
      totalIncome: income,
      totalExpense: expense,
      balance: income - expense,
      savingsRate: savingsRate,
      categorySpending: spending,
      topCategories: sorted.map((e) => e.key).toList(),
    );
  }
}

final currentMonthStatsProvider = StreamProvider<MonthlyStats>((ref) {
  final txStream = ref.watch(transactionsProvider.future).asStream();
  return ref.watch(transactionsProvider.stream).map((transactions) {
    final now = DateTime.now();
    final thisMonth = transactions.where((tx) =>
        tx.date.year == now.year && tx.date.month == now.month).toList();
    return MonthlyStats.fromTransactions(thisMonth);
  });
});

// ─── FINANCIAL HEALTH SCORE ──────────────────────────────────────────────────

class FinancialScore {
  final int score;
  final String grade;
  final int savingsScore;
  final int debtScore;
  final int investScore;
  final List<String> insights;
  final List<AppTransaction> anomalies;

  FinancialScore({
    required this.score, required this.grade,
    required this.savingsScore, required this.debtScore, required this.investScore,
    required this.insights, required this.anomalies,
  });

  factory FinancialScore.empty() => FinancialScore(
    score: 50, grade: 'C', savingsScore: 50, debtScore: 50, investScore: 50,
    insights: [], anomalies: [],
  );
}

final financialScoreProvider = Provider<FinancialScore>((ref) {
  final txAsync = ref.watch(transactionsProvider);
  return txAsync.when(
    loading: () => FinancialScore.empty(),
    error: (_, __) => FinancialScore.empty(),
    data: (transactions) {
      if (transactions.isEmpty) return FinancialScore.empty();

      final now = DateTime.now();
      final recent = transactions.where((tx) =>
          tx.date.isAfter(now.subtract(const Duration(days: 90)))).toList();

      final stats = MonthlyStats.fromTransactions(
        transactions.where((tx) => tx.date.year == now.year && tx.date.month == now.month).toList()
      );

      // Savings score
      int savingsScore = (stats.savingsRate * 4).clamp(0, 100).toInt();

      // Debt score (penalize high debt/EMI spend)
      final debtSpend = (stats.categorySpending['Debt'] ?? 0) + (stats.categorySpending['EMI'] ?? 0);
      final dtiRatio = stats.totalIncome > 0 ? debtSpend / stats.totalIncome : 0;
      int debtScore = (100 - (dtiRatio * 200).clamp(0, 80)).toInt();

      // Investment score
      final investSpend = stats.categorySpending['Invest'] ?? 0;
      final investRate = stats.totalIncome > 0 ? investSpend / stats.totalIncome : 0;
      int investScore = (investRate * 500).clamp(10, 100).toInt();

      final overallScore = ((savingsScore * 0.4) + (debtScore * 0.3) + (investScore * 0.3)).toInt();
      String grade = 'D';
      if (overallScore >= 90) grade = 'A+';
      else if (overallScore >= 80) grade = 'A';
      else if (overallScore >= 70) grade = 'B';
      else if (overallScore >= 60) grade = 'C';

      // Anomalies: transactions 2x above their category average
      final List<AppTransaction> anomalies = [];
      final Map<String, List<double>> catAmounts = {};
      for (final tx in recent.where((t) => t.type == TransactionType.expense)) {
        catAmounts.putIfAbsent(tx.category, () => []).add(tx.amount.abs());
      }
      for (final tx in recent.where((t) => t.type == TransactionType.expense)) {
        final amounts = catAmounts[tx.category] ?? [];
        if (amounts.length < 2) continue;
        final avg = amounts.reduce((a, b) => a + b) / amounts.length;
        if (tx.amount.abs() > avg * 2 && tx.amount.abs() > 1000) {
          anomalies.add(tx);
        }
      }

      final List<String> insights = [];
      if (stats.savingsRate < 20) insights.add('Savings rate is ${stats.savingsRate.toStringAsFixed(1)}% — target 20%');
      if (dtiRatio > 0.3) insights.add('Debt payments are ${(dtiRatio * 100).toStringAsFixed(0)}% of income');
      if (investRate < 0.05 && stats.totalIncome > 0) insights.add('Investing less than 5% of income');
      if (anomalies.isNotEmpty) insights.add('${anomalies.length} unusual transaction(s) detected');

      return FinancialScore(
        score: overallScore.clamp(0, 100),
        grade: grade,
        savingsScore: savingsScore.clamp(0, 100),
        debtScore: debtScore.clamp(0, 100),
        investScore: investScore.clamp(0, 100),
        insights: insights,
        anomalies: anomalies,
      );
    },
  );
});

// ─── AI RECOMMENDATIONS ─────────────────────────────────────────────────────

final aiRecommendationsProvider = FutureProvider<List<String>>((ref) async {
  final stats = await ref.watch(currentMonthStatsProvider.future);
  if (stats.totalIncome == 0 && stats.totalExpense == 0) {
    return ['Add your income and expenses to get personalized tips', 'Use the + button to log your first transaction', 'Enable SMS detection to auto-import UPI payments'];
  }
  final gemini = ref.read(geminiServiceProvider);
  return gemini.getFinancialRecommendations(
    monthlyIncome: stats.totalIncome,
    monthlyExpense: stats.totalExpense,
    savingsRate: stats.savingsRate,
    categorySpending: stats.categorySpending,
    topCategories: stats.topCategories,
  );
});

// ─── LAST 6 MONTHS CHART DATA ────────────────────────────────────────────────

class MonthlyChartData {
  final String month;
  final double expense;
  final bool isProjected;
  MonthlyChartData(this.month, this.expense, {this.isProjected = false});
}

final last6MonthsChartProvider = Provider<List<MonthlyChartData>>((ref) {
  final txAsync = ref.watch(transactionsProvider);
  return txAsync.when(
    loading: () => [],
    error: (_, __) => [],
    data: (transactions) {
      final now = DateTime.now();
      final months = List.generate(6, (i) {
        final date = DateTime(now.year, now.month - 5 + i, 1);
        return date;
      });

      final maxExpense = 1.0;
      final data = months.map((date) {
        final monthTx = transactions.where((tx) =>
            tx.date.year == date.year && tx.date.month == date.month &&
            tx.type == TransactionType.expense);
        final total = monthTx.fold(0.0, (sum, tx) => sum + tx.amount.abs());
        final label = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][date.month - 1];
        final isCurrentMonth = date.month == now.month && date.year == now.year;
        return MonthlyChartData(label, total, isProjected: isCurrentMonth);
      }).toList();

      return data;
    },
  );
});

// ─── BUDGETS ─────────────────────────────────────────────────────────────────

final budgetsProvider = StreamProvider<List<Budget>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getBudgets(user.uid);
});

// Budgets merged with actual spending from current month
final budgetWithSpendingProvider = Provider<List<Budget>>((ref) {
  final budgetsAsync = ref.watch(budgetsProvider);
  final statsAsync = ref.watch(currentMonthStatsProvider);

  final budgets = budgetsAsync.value ?? [];
  final stats = statsAsync.value ?? MonthlyStats.empty();

  return budgets.map((b) => b.copyWith(spent: stats.categorySpending[b.category] ?? 0)).toList();
});
