import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import '../../models/transaction.dart';

class AIScannerService {
  final GenerativeModel _model;

  AIScannerService({required String apiKey})
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.2, // Low temperature for more deterministic parsing
            responseMimeType: 'application/json',
          ),
        );

  Future<AppTransaction?> parseReceiptText(String text, String userId) async {
    try {
      final prompt = '''
You are a highly intelligent financial receipt parser. 
Extract the following information from the OCR text of a receipt and return it strictly as a JSON object matching this schema:
{
  "title": "Store or Merchant Name",
  "amount": 0.00,
  "category": "Food, Shopping, Bills, Transport, Health, Entertainment, or Other",
  "date": "YYYY-MM-DD" // If date is missing, omit the field or set to null
}

Here is the raw OCR text:
"""
$text
"""
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      final responseText = response.text;
      if (responseText == null) return null;

      final parsed = jsonDecode(responseText) as Map<String, dynamic>;

      return AppTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: parsed['title'] ?? 'Unknown Merchant',
        amount: -(parsed['amount'] ?? 0.0).toDouble().abs(), // Expenses are negative
        type: TransactionType.expense,
        category: parsed['category'] ?? 'Other',
        date: parsed['date'] != null ? DateTime.parse(parsed['date']) : DateTime.now(),
        paymentMethod: 'Scanner',
      );
    } catch (e) {
      debugPrint('AI Parsing error: $e');
      return null;
    }
  }
}
