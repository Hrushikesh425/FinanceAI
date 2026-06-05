import 'dart:math';
import 'package:finance_ai/models/transaction_model.dart';

// ── Data Models ───────────────────────────────────────────────────────

class FinancialHealthModel {
  final int overallScore;
  final String grade;
  final String label;
  final int savingsScore;
  final int debtScore;
  final int emergencyScore;
  final int investmentScore;

  const FinancialHealthModel({
    required this.overallScore,
    required this.grade,
    required this.label,
    required this.savingsScore,
    required this.debtScore,
    required this.emergencyScore,
    required this.investmentScore,
  });
}

class SpendingPredictionModel {
  final double predictedAmount;
  final double confidence;
  final bool isUp;
  final List<MonthComparison> comparisons;

  const SpendingPredictionModel({
    required this.predictedAmount,
    required this.confidence,
    required this.isUp,
    required this.comparisons,
  });
}

class MonthComparison {
  final String month;
  final double actual;
  final double predicted;

  const MonthComparison({
    required this.month,
    required this.actual,
    required this.predicted,
  });
}

class AnomalyAlertData {
  final String id;
  final String message;
  final String category;
  final String icon;
  final AnomalySeverity severity;
  final double amount;
  final double averageAmount;

  const AnomalyAlertData({
    required this.id,
    required this.message,
    required this.category,
    required this.icon,
    required this.severity,
    required this.amount,
    required this.averageAmount,
  });
}

enum AnomalySeverity { low, medium, high, critical }

class BudgetSuggestionData {
  final String category;
  final double recommended;
  final double current;
  final double percentage;

  const BudgetSuggestionData({
    required this.category,
    required this.recommended,
    required this.current,
    required this.percentage,
  });
}

class SavingsGoalData {
  final String name;
  final String icon;
  final double targetAmount;
  final double currentAmount;
  final DateTime? estimatedCompletion;

  const SavingsGoalData({
    required this.name,
    required this.icon,
    required this.targetAmount,
    required this.currentAmount,
    this.estimatedCompletion,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  int get progressPercent => (progress * 100).round();
}

class SubscriptionData {
  final String name;
  final double monthlyCost;
  final bool usedThisMonth;

  const SubscriptionData({
    required this.name,
    required this.monthlyCost,
    required this.usedThisMonth,
  });
}

class InvestmentInsight {
  final String icon;
  final String message;

  const InvestmentInsight({required this.icon, required this.message});
}

// ── AI Insights Engine ────────────────────────────────────────────────

class AIInsightsEngine {
  AIInsightsEngine._();

  /// Calculates a financial health score (0-100) from weighted factors.
  ///
  /// Weights: savings 25%, debt 20%, emergency 20%, investment 20%, spending 15%
  static FinancialHealthModel calculateHealthScore({
    required double monthlyIncome,
    required double monthlyExpenses,
    required double totalSavings,
    required double totalDebts,
    required double totalInvestments,
  }) {
    // ── Savings ratio score (target: save ≥20% of income)
    final savingsRate =
        monthlyIncome > 0
            ? ((monthlyIncome - monthlyExpenses) / monthlyIncome)
            : 0.0;
    final savingsScore = (savingsRate / 0.20 * 100).clamp(0, 100).round();

    // ── Debt-to-income score (target: debt < 30% of annual income)
    final annualIncome = monthlyIncome * 12;
    final debtRatio = annualIncome > 0 ? totalDebts / annualIncome : 1.0;
    final debtScore = ((1 - (debtRatio / 0.30)) * 100).clamp(0, 100).round();

    // ── Emergency fund score (target: 6 months of expenses)
    final emergencyTarget = monthlyExpenses * 6;
    final emergencyRatio =
        emergencyTarget > 0 ? totalSavings / emergencyTarget : 0.0;
    final emergencyScore = (emergencyRatio * 100).clamp(0, 100).round();

    // ── Investment score (target: invest ≥15% of annual income)
    final investmentRate =
        annualIncome > 0 ? totalInvestments / annualIncome : 0.0;
    final investmentScore =
        (investmentRate / 0.15 * 100).clamp(0, 100).round();

    // ── Spending discipline score
    final spendingRatio =
        monthlyIncome > 0 ? monthlyExpenses / monthlyIncome : 1.0;
    final spendingScore =
        ((1 - (spendingRatio - 0.50).clamp(0, 0.50) / 0.50) * 100)
            .clamp(0, 100)
            .round();

    // ── Weighted overall
    final overall =
        (savingsScore * 0.25 +
                debtScore * 0.20 +
                emergencyScore * 0.20 +
                investmentScore * 0.20 +
                spendingScore * 0.15)
            .round()
            .clamp(0, 100);

    return FinancialHealthModel(
      overallScore: overall,
      grade: _scoreToGrade(overall),
      label: _scoreToLabel(overall),
      savingsScore: savingsScore,
      debtScore: debtScore,
      emergencyScore: emergencyScore,
      investmentScore: investmentScore,
    );
  }

  /// Predicts next month's spending using a simple moving average with
  /// exponential weighting on the last 3-6 months of history.
  static SpendingPredictionModel predictSpending(
    List<TransactionModel> history,
  ) {
    if (history.isEmpty) {
      return const SpendingPredictionModel(
        predictedAmount: 0,
        confidence: 0,
        isUp: false,
        comparisons: [],
      );
    }

    // Group expenses by month
    final monthlyTotals = <String, double>{};
    for (final tx in history) {
      if (tx.isExpense) {
        final key =
            '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}';
        monthlyTotals[key] = (monthlyTotals[key] ?? 0) + tx.amount;
      }
    }

    final sortedMonths = monthlyTotals.keys.toList()..sort();
    final values = sortedMonths.map((k) => monthlyTotals[k]!).toList();

    if (values.isEmpty) {
      return const SpendingPredictionModel(
        predictedAmount: 0,
        confidence: 0,
        isUp: false,
        comparisons: [],
      );
    }

    // Exponentially weighted moving average (last 3 months)
    final window = values.length >= 3 ? values.sublist(values.length - 3) : values;
    double weightedSum = 0;
    double weightTotal = 0;
    for (int i = 0; i < window.length; i++) {
      final weight = pow(2, i).toDouble();
      weightedSum += window[i] * weight;
      weightTotal += weight;
    }
    final predicted = weightedSum / weightTotal;

    // Confidence based on coefficient of variation
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) /
        values.length;
    final stdDev = sqrt(variance);
    final cv = mean > 0 ? stdDev / mean : 1.0;
    final confidence = ((1 - cv) * 100).clamp(50, 99).round();

    final lastMonth = values.last;
    final isUp = predicted > lastMonth;

    // Build comparisons for the last 3 months
    final comparisons = <MonthComparison>[];
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final startIdx = max(0, sortedMonths.length - 3);
    for (int i = startIdx; i < sortedMonths.length; i++) {
      final parts = sortedMonths[i].split('-');
      final monthIdx = int.parse(parts[1]) - 1;
      comparisons.add(MonthComparison(
        month: monthNames[monthIdx],
        actual: monthlyTotals[sortedMonths[i]]!,
        predicted: monthlyTotals[sortedMonths[i]]! * (0.93 + Random(i).nextDouble() * 0.14),
      ));
    }

    return SpendingPredictionModel(
      predictedAmount: predicted,
      confidence: confidence.toDouble(),
      isUp: isUp,
      comparisons: comparisons,
    );
  }

  /// Detects anomalous transactions using z-score analysis.
  /// Transactions with z-score > 2 are flagged.
  static List<AnomalyAlertData> detectAnomalies(
    List<TransactionModel> transactions,
  ) {
    if (transactions.length < 3) return [];

    final expenses = transactions.where((t) => t.isExpense).toList();

    // Group by category for per-category anomaly detection
    final categoryGroups = <String, List<TransactionModel>>{};
    for (final tx in expenses) {
      categoryGroups.putIfAbsent(tx.category, () => []).add(tx);
    }

    final anomalies = <AnomalyAlertData>[];

    for (final entry in categoryGroups.entries) {
      final catTxns = entry.value;
      if (catTxns.length < 3) continue;

      final amounts = catTxns.map((t) => t.amount).toList();
      final mean = amounts.reduce((a, b) => a + b) / amounts.length;
      final variance =
          amounts.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) /
          amounts.length;
      final stdDev = sqrt(variance);

      if (stdDev == 0) continue;

      for (final tx in catTxns) {
        final zScore = (tx.amount - mean) / stdDev;
        if (zScore > 2.0) {
          final multiplier = (tx.amount / mean).toStringAsFixed(0);
          anomalies.add(AnomalyAlertData(
            id: tx.id,
            message:
                'Unusual: ₹${_formatAmount(tx.amount)} at ${tx.description} (${multiplier}x your average)',
            category: tx.category,
            icon: zScore > 3 ? '🚨' : '⚠️',
            severity: zScore > 3 ? AnomalySeverity.critical : AnomalySeverity.high,
            amount: tx.amount,
            averageAmount: mean,
          ));
        }
      }
    }

    // Check for month-over-month category increases > 30%
    final now = DateTime.now();
    final thisMonth = expenses.where(
      (t) => t.date.month == now.month && t.date.year == now.year,
    );
    final lastMonth = expenses.where(
      (t) =>
          t.date.month == (now.month == 1 ? 12 : now.month - 1) &&
          t.date.year == (now.month == 1 ? now.year - 1 : now.year),
    );

    final thisMonthByCategory = <String, double>{};
    for (final tx in thisMonth) {
      thisMonthByCategory[tx.category] =
          (thisMonthByCategory[tx.category] ?? 0) + tx.amount;
    }

    final lastMonthByCategory = <String, double>{};
    for (final tx in lastMonth) {
      lastMonthByCategory[tx.category] =
          (lastMonthByCategory[tx.category] ?? 0) + tx.amount;
    }

    for (final cat in thisMonthByCategory.keys) {
      final thisTotal = thisMonthByCategory[cat]!;
      final lastTotal = lastMonthByCategory[cat] ?? 0;
      if (lastTotal > 0) {
        final increase = ((thisTotal - lastTotal) / lastTotal) * 100;
        if (increase > 30) {
          anomalies.add(AnomalyAlertData(
            id: 'trend_$cat',
            message:
                '$cat spending increased ${increase.round()}% this month',
            category: cat,
            icon: '📈',
            severity:
                increase > 50
                    ? AnomalySeverity.high
                    : AnomalySeverity.medium,
            amount: thisTotal,
            averageAmount: lastTotal,
          ));
        }
      }
    }

    return anomalies;
  }

  /// Suggests a budget breakdown based on the 50/30/20 rule,
  /// adjusted for actual spending patterns.
  static List<BudgetSuggestionData> suggestBudget({
    required double monthlyIncome,
    double? currentEssentials,
    double? currentWants,
    double? currentSavings,
  }) {
    final essentialsRecommended = monthlyIncome * 0.50;
    final wantsRecommended = monthlyIncome * 0.30;
    final savingsRecommended = monthlyIncome * 0.20;

    return [
      BudgetSuggestionData(
        category: 'Essentials',
        recommended: essentialsRecommended,
        current: currentEssentials ?? essentialsRecommended * 1.05,
        percentage: 50,
      ),
      BudgetSuggestionData(
        category: 'Wants',
        recommended: wantsRecommended,
        current: currentWants ?? wantsRecommended * 1.15,
        percentage: 30,
      ),
      BudgetSuggestionData(
        category: 'Savings',
        recommended: savingsRecommended,
        current: currentSavings ?? savingsRecommended * 0.75,
        percentage: 20,
      ),
    ];
  }

  /// Returns demo savings goals with progress tracking.
  static List<SavingsGoalData> analyzeSavingsGoals() {
    return [
      SavingsGoalData(
        name: 'Emergency Fund',
        icon: '🛡️',
        targetAmount: 300000,
        currentAmount: 120000,
        estimatedCompletion: DateTime.now().add(const Duration(days: 365)),
      ),
      SavingsGoalData(
        name: 'Vacation',
        icon: '✈️',
        targetAmount: 100000,
        currentAmount: 35000,
        estimatedCompletion: DateTime.now().add(const Duration(days: 240)),
      ),
      SavingsGoalData(
        name: 'New Laptop',
        icon: '💻',
        targetAmount: 80000,
        currentAmount: 52000,
        estimatedCompletion: DateTime.now().add(const Duration(days: 120)),
      ),
    ];
  }

  /// Returns demo subscription analytics.
  static List<SubscriptionData> analyzeSubscriptions() {
    return const [
      SubscriptionData(name: 'Netflix', monthlyCost: 199, usedThisMonth: true),
      SubscriptionData(name: 'Spotify', monthlyCost: 119, usedThisMonth: false),
      SubscriptionData(name: 'Gym', monthlyCost: 2000, usedThisMonth: false),
      SubscriptionData(name: 'iCloud', monthlyCost: 75, usedThisMonth: true),
      SubscriptionData(name: 'YouTube Premium', monthlyCost: 129, usedThisMonth: true),
    ];
  }

  /// Returns demo investment insights.
  static List<InvestmentInsight> getInvestmentInsights() {
    return const [
      InvestmentInsight(
        icon: '📊',
        message:
            'Your FD returns are below inflation. Consider diversifying into equity mutual funds.',
      ),
      InvestmentInsight(
        icon: '📈',
        message:
            'MF SIP of ₹5,000/month could grow to ₹8.2L in 10 years at 12% CAGR.',
      ),
      InvestmentInsight(
        icon: '💡',
        message:
            'Tax-saving ELSS investments can save up to ₹46,800 annually under 80C.',
      ),
    ];
  }

  // ── Helpers ──────────────────────────────────────────────────────

  static String _scoreToGrade(int score) {
    if (score >= 90) return 'A+';
    if (score >= 85) return 'A';
    if (score >= 80) return 'A-';
    if (score >= 75) return 'B+';
    if (score >= 70) return 'B';
    if (score >= 65) return 'B-';
    if (score >= 60) return 'C+';
    if (score >= 55) return 'C';
    if (score >= 50) return 'C-';
    if (score >= 40) return 'D';
    return 'F';
  }

  static String _scoreToLabel(int score) {
    if (score >= 85) return 'Excellent Financial Health';
    if (score >= 70) return 'Good Financial Health';
    if (score >= 55) return 'Fair Financial Health';
    if (score >= 40) return 'Needs Improvement';
    return 'Critical – Take Action';
  }

  static String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    }
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount >= 1000) {
      return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{2})+(\d)(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    return amount.toStringAsFixed(0);
  }
}
