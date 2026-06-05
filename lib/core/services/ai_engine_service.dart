import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transaction_model.dart';
import '../../models/financial_health_model.dart';

final aiEngineProvider = Provider<AiEngineService>((ref) => AiEngineService());

class AiEngineService {
  
  /// Calculates a simple 0-100 financial health score based on basic rules:
  /// - High savings rate = higher score
  /// - Low debt-to-income = higher score
  /// - Essential vs Discretionary spending balance
  FinancialHealthModel calculateFinancialHealth(List<TransactionModel> transactions, double monthlyIncome) {
    if (transactions.isEmpty || monthlyIncome <= 0) {
      return FinancialHealthModel(
        id: '1',
        userId: 'temp',
        score: 50,
        grade: 'C',
        savingsRate: 0,
        debtToIncomeRatio: 0,
        lastUpdated: DateTime.now(),
        insights: ['Not enough data to calculate financial health.'],
        recommendations: ['Start adding your daily expenses.'],
      );
    }

    double totalExpenses = 0;
    double essentialExpenses = 0; // housing, food, utilities
    double debtPayments = 0; // EMIs, credit cards
    
    for (var t in transactions) {
      if (t.type == TransactionType.expense) {
        totalExpenses += t.amount;
        if (t.category == 'Housing' || t.category == 'Food' || t.category == 'Utilities') {
          essentialExpenses += t.amount;
        } else if (t.category == 'Debt' || t.category == 'EMI') {
          debtPayments += t.amount;
        }
      }
    }

    // 1. Savings Rate (ideal: >= 20%)
    double savingsRate = ((monthlyIncome - totalExpenses) / monthlyIncome) * 100;
    if (savingsRate < 0) savingsRate = 0;
    
    // 2. Debt to Income Ratio (ideal: <= 30%)
    double dti = (debtPayments / monthlyIncome) * 100;

    // 3. Needs Ratio (ideal: <= 50%)
    double needsRatio = (essentialExpenses / monthlyIncome) * 100;

    // Calculate composite score (out of 100)
    double score = 100;
    
    // Penalize low savings
    if (savingsRate < 20) score -= (20 - savingsRate) * 1.5;
    
    // Penalize high DTI
    if (dti > 30) score -= (dti - 30) * 1.5;
    
    // Penalize high essential spending
    if (needsRatio > 50) score -= (needsRatio - 50);

    score = score.clamp(0, 100);

    // Assign grade
    String grade = 'F';
    if (score >= 90) grade = 'A+';
    else if (score >= 80) grade = 'A';
    else if (score >= 70) grade = 'B';
    else if (score >= 60) grade = 'C';
    else if (score >= 50) grade = 'D';

    // Generate dynamic text insights
    List<String> insights = [];
    List<String> recommendations = [];

    if (savingsRate >= 20) {
      insights.add('Great job saving ${savingsRate.toStringAsFixed(1)}% of your income!');
    } else {
      insights.add('Your savings rate is ${savingsRate.toStringAsFixed(1)}%, which is below the recommended 20%.');
      recommendations.add('Try cutting back on non-essential categories like dining out.');
    }

    if (dti > 30) {
      insights.add('Your debt payments are taking up ${dti.toStringAsFixed(1)}% of your income.');
      recommendations.add('Focus on paying down high-interest debt aggressively.');
    }

    return FinancialHealthModel(
      id: '1',
      userId: 'temp',
      score: score.toInt(),
      grade: grade,
      savingsRate: savingsRate,
      debtToIncomeRatio: dti,
      lastUpdated: DateTime.now(),
      insights: insights,
      recommendations: recommendations,
    );
  }

  /// Detects anomalies: any transaction > 2x the category average
  List<TransactionModel> detectAnomalies(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return [];

    // Group by category and find averages
    Map<String, List<double>> categorySpends = {};
    for (var t in transactions.where((t) => t.type == TransactionType.expense)) {
      if (!categorySpends.containsKey(t.category)) {
        categorySpends[t.category] = [];
      }
      categorySpends[t.category]!.add(t.amount);
    }

    Map<String, double> categoryAverages = {};
    categorySpends.forEach((cat, amounts) {
      double avg = amounts.reduce((a, b) => a + b) / amounts.length;
      categoryAverages[cat] = avg;
    });

    // Find transactions > 2x average (and > 1000 INR to filter out noise)
    List<TransactionModel> anomalies = [];
    for (var t in transactions.where((t) => t.type == TransactionType.expense)) {
      double avg = categoryAverages[t.category] ?? 0;
      if (t.amount > 1000 && t.amount > (avg * 2)) {
        anomalies.add(t);
      }
    }

    return anomalies;
  }
}
