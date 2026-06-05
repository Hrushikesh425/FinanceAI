import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transaction_model.dart';
import '../../models/financial_health_model.dart';

final aiEngineProvider = Provider<AiEngineService>((ref) => AiEngineService());

class AiEngineService {
  
  FinancialHealthModel calculateFinancialHealth(List<TransactionModel> transactions, double monthlyIncome) {
    if (transactions.isEmpty || monthlyIncome <= 0) {
      return FinancialHealthModel(
        overallScore: 50,
        grade: 'C',
        savingsRate: 0,
        debtToIncomeRatio: 0,
        calculatedAt: DateTime.now(),
      );
    }

    double totalExpenses = 0;
    double essentialExpenses = 0;
    double debtPayments = 0;
    
    for (var t in transactions) {
      if (t.type == 'expense') {
        totalExpenses += t.amount;
        if (t.category == 'Housing' || t.category == 'Food' || t.category == 'Utilities') {
          essentialExpenses += t.amount;
        } else if (t.category == 'Debt' || t.category == 'EMI') {
          debtPayments += t.amount;
        }
      }
    }

    double savingsRate = ((monthlyIncome - totalExpenses) / monthlyIncome) * 100;
    if (savingsRate < 0) savingsRate = 0;
    
    double dti = (debtPayments / monthlyIncome) * 100;
    double needsRatio = (essentialExpenses / monthlyIncome) * 100;

    double score = 100;
    if (savingsRate < 20) score -= (20 - savingsRate) * 1.5;
    if (dti > 30) score -= (dti - 30) * 1.5;
    if (needsRatio > 50) score -= (needsRatio - 50);
    score = score.clamp(0, 100);

    String grade = 'F';
    if (score >= 90) grade = 'A+';
    else if (score >= 80) grade = 'A';
    else if (score >= 70) grade = 'B';
    else if (score >= 60) grade = 'C';
    else if (score >= 50) grade = 'D';

    List<String> tips = [];
    if (savingsRate >= 20) {
      tips.add('Great job saving ${savingsRate.toStringAsFixed(1)}% of your income!');
    } else {
      tips.add('Your savings rate is ${savingsRate.toStringAsFixed(1)}%, below the recommended 20%.');
      tips.add('Try cutting back on non-essential categories like dining out.');
    }
    if (dti > 30) {
      tips.add('Your debt payments are taking up ${dti.toStringAsFixed(1)}% of your income.');
      tips.add('Focus on paying down high-interest debt aggressively.');
    }

    return FinancialHealthModel(
      overallScore: score,
      grade: grade,
      savingsRate: savingsRate,
      debtToIncomeRatio: dti,
      calculatedAt: DateTime.now(),
      tips: tips,
    );
  }

  List<TransactionModel> detectAnomalies(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return [];

    Map<String, List<double>> categorySpends = {};
    for (var t in transactions.where((t) => t.type == 'expense')) {
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

    List<TransactionModel> anomalies = [];
    for (var t in transactions.where((t) => t.type == 'expense')) {
      double avg = categoryAverages[t.category] ?? 0;
      if (t.amount > 1000 && t.amount > (avg * 2)) {
        anomalies.add(t);
      }
    }

    return anomalies;
  }
}
