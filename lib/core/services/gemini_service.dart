import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:finance_ai/core/models/transaction.dart';

class GeminiService {
  static const _apiKey = 'AIzaSyDTITX8GVzJr9eJdrBKihd54bbstRaeic4';

  final GenerativeModel _textModel = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
  );

  final GenerativeModel _visionModel = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
  );

  // ─── AI RECOMMENDATIONS ──────────────────────────────────────────────────────

  Future<List<String>> getFinancialRecommendations({
    required double monthlyIncome,
    required double monthlyExpense,
    required double savingsRate,
    required Map<String, double> categorySpending,
    required List<String> topCategories,
  }) async {
    try {
      final categoryText = categorySpending.entries
          .map((e) => '${e.key}: ₹${e.value.toStringAsFixed(0)}')
          .join(', ');

      final prompt = '''
You are a smart personal finance advisor for an Indian user. Analyze this monthly data and give 3 concise, actionable recommendations in JSON format.

Monthly Income: ₹${monthlyIncome.toStringAsFixed(0)}
Monthly Expenses: ₹${monthlyExpense.toStringAsFixed(0)}
Savings Rate: ${savingsRate.toStringAsFixed(1)}%
Spending by Category: $categoryText
Top Spending Categories: ${topCategories.take(3).join(', ')}

Return ONLY a JSON array of 3 strings, each a short actionable tip (max 15 words each). Example:
["Reduce food delivery spend by ₹2,000 to boost savings", "Allocate 5% income to mutual funds via SIP", "Set ₹5,000 limit for entertainment this month"]
''';

      final response = await _textModel.generateContent([Content.text(prompt)]);
      final text = response.text ?? '[]';
      
      // Extract JSON array from response
      final jsonMatch = RegExp(r'\[.*?\]', dotAll: true).firstMatch(text);
      if (jsonMatch != null) {
        final List<dynamic> parsed = jsonDecode(jsonMatch.group(0)!);
        return parsed.cast<String>();
      }
      return _defaultRecommendations(savingsRate, categorySpending);
    } catch (e) {
      debugPrint('Gemini recommendations error: $e');
      return _defaultRecommendations(savingsRate, categorySpending);
    }
  }

  List<String> _defaultRecommendations(double savingsRate, Map<String, double> spending) {
    final tips = <String>[];
    if (savingsRate < 20) tips.add('Try to save at least 20% of your monthly income');
    if ((spending['Food'] ?? 0) > 5000) tips.add('Food spend is high — try cooking at home more often');
    if ((spending['Shopping'] ?? 0) > 3000) tips.add('Reduce impulse shopping by using a 24-hour rule');
    tips.add('Start a ₹500/month SIP in an index fund for long-term wealth');
    return tips.take(3).toList();
  }

  // ─── AI SPENDING PREDICTION ──────────────────────────────────────────────────

  Future<double> predictNextMonthSpend(List<double> last6MonthsExpenses) async {
    if (last6MonthsExpenses.isEmpty) return 0;
    try {
      final avg = last6MonthsExpenses.reduce((a, b) => a + b) / last6MonthsExpenses.length;
      final prompt = '''
Given these last ${last6MonthsExpenses.length} months of expenses in INR: ${last6MonthsExpenses.map((e) => e.toStringAsFixed(0)).join(', ')}
Predict next month's total expense. Return ONLY a single number (no text, no symbol). Example: 45200
''';
      final response = await _textModel.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';
      final match = RegExp(r'[\d,]+').firstMatch(text);
      if (match != null) {
        return double.tryParse(match.group(0)!.replaceAll(',', '')) ?? avg;
      }
      return avg;
    } catch (e) {
      return last6MonthsExpenses.reduce((a, b) => a + b) / last6MonthsExpenses.length;
    }
  }

  // ─── RECEIPT SCANNER ─────────────────────────────────────────────────────────

  Future<AppTransaction?> parseReceiptImage(Uint8List imageBytes, String userId) async {
    try {
      final prompt = '''
You are a receipt parser. Analyze this receipt image and extract transaction data.
Return ONLY a JSON object with these exact fields (no extra text):
{
  "title": "merchant name or store name",
  "amount": total amount as number (positive),
  "category": one of: Food, Shopping, Transport, Bills, Health, Fun, Education, Other,
  "paymentMethod": one of: UPI, Cash, Credit Card, Debit Card,
  "date": "YYYY-MM-DD" (today if not visible)
}
If this is not a receipt, return: {"error": "not a receipt"}
''';

      final response = await _visionModel.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ]);

      final text = response.text ?? '';
      final jsonMatch = RegExp(r'\{.*?\}', dotAll: true).firstMatch(text);
      if (jsonMatch == null) return null;

      final data = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
      if (data.containsKey('error')) return null;

      return AppTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: data['title']?.toString() ?? 'Receipt',
        amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
        type: TransactionType.expense,
        category: data['category']?.toString() ?? 'Other',
        date: DateTime.tryParse(data['date']?.toString() ?? '') ?? DateTime.now(),
        paymentMethod: data['paymentMethod']?.toString() ?? 'UPI',
        subtitle: 'Scanned receipt',
      );
    } catch (e) {
      debugPrint('Receipt parse error: $e');
      return null;
    }
  }

  // ─── CHAT / Q&A ──────────────────────────────────────────────────────────────

  Future<String> askFinanceQuestion(String question, {String context = ''}) async {
    try {
      final prompt = context.isNotEmpty
          ? 'Context: $context\n\nUser question: $question\n\nAnswer in 2-3 sentences, in simple English for an Indian user.'
          : '$question\n\nAnswer in 2-3 sentences, in simple English for an Indian user focused on personal finance.';
      final response = await _textModel.generateContent([Content.text(prompt)]);
      return response.text ?? 'I could not process your question. Please try again.';
    } catch (e) {
      return 'Unable to connect to AI service. Please check your internet connection.';
    }
  }
}
