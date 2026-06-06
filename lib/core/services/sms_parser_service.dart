import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:finance_ai/core/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmsParserService {
  final SmsQuery _query = SmsQuery();

  // Regex for Indian UPI/Bank SMS formats
  // Example: "Rs. 450.00 debited from a/c **1234 on 12-04-24 to Swiggy. Ref 410328"
  // Example: "Sent Rs. 500 to Rahul via UPI"
  final _debitRegexes = [
    RegExp(r'(?:Rs\.?|INR)\s*([\d,]+\.?\d*)\s*(?:debited|deducted|spent|withdrawn)', caseSensitive: false),
    RegExp(r'(?:debited|deducted|spent|withdrawn).*?(?:Rs\.?|INR)\s*([\d,]+\.?\d*)', caseSensitive: false),
    RegExp(r'sent\s*(?:Rs\.?|INR)\s*([\d,]+\.?\d*)', caseSensitive: false),
  ];

  final _merchantRegexes = [
    RegExp(r'(?:to|at|info|vpa)\s+([A-Za-z0-9@]+(?:\s+[A-Za-z0-9]+){0,2})', caseSensitive: false),
  ];

  Future<List<AppTransaction>> extractRecentUpiTransactions(String userId) async {
    try {
      final permission = await Permission.sms.request();
      if (!permission.isGranted) {
        debugPrint('SMS permission denied');
        return [];
      }

      // We only want to process SMS received since the last check
      final prefs = await SharedPreferences.getInstance();
      final lastCheckTime = prefs.getInt('last_sms_check_time') ?? 
          DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch;
          
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 50,
      );

      final newTransactions = <AppTransaction>[];
      final currentCheckTime = DateTime.now().millisecondsSinceEpoch;

      for (final msg in messages) {
        if (msg.date == null || msg.body == null) continue;
        
        // Skip old messages
        if (msg.date!.millisecondsSinceEpoch <= lastCheckTime) continue;

        final body = msg.body!.toLowerCase();
        
        // Only look at typical banking/UPI sender IDs (usually 6 letters like AD-HDFCBK)
        // and ensure the message contains debit keywords
        if (msg.sender != null && 
            !msg.sender!.contains(RegExp(r'\d')) && 
            (body.contains('debited') || body.contains('sent ') || body.contains('paid '))) {
          
          final tx = _parseMessage(msg.body!, msg.date!, userId);
          if (tx != null) {
            newTransactions.add(tx);
          }
        }
      }

      // Update last check time
      await prefs.setInt('last_sms_check_time', currentCheckTime);
      
      return newTransactions;
    } catch (e) {
      debugPrint('SMS parsing error: $e');
      return [];
    }
  }

  AppTransaction? _parseMessage(String body, DateTime date, String userId) {
    double? amount;
    String? merchant;

    // Extract amount
    for (final regex in _debitRegexes) {
      final match = regex.firstMatch(body);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '');
        amount = double.tryParse(amountStr ?? '');
        break;
      }
    }

    if (amount == null) return null;

    // Extract merchant
    for (final regex in _merchantRegexes) {
      final match = regex.firstMatch(body);
      if (match != null) {
        merchant = match.group(1)?.trim();
        // Clean up common false positives
        if (merchant == 'your' || merchant == 'a/c' || merchant == 'account') {
          merchant = null;
          continue;
        }
        break;
      }
    }

    // Default category mapping based on merchant name
    String category = 'Other';
    merchant = merchant?.toUpperCase() ?? 'UPI PAYMENT';
    if (merchant.contains('ZOMATO') || merchant.contains('SWIGGY') || merchant.contains('RESTAURANT')) category = 'Food';
    if (merchant.contains('AMAZON') || merchant.contains('FLIPKART') || merchant.contains('MYNTRA')) category = 'Shopping';
    if (merchant.contains('UBER') || merchant.contains('OLA') || merchant.contains('IRCTC')) category = 'Transport';
    if (merchant.contains('AIRTEL') || merchant.contains('JIO') || merchant.contains('BESCOM')) category = 'Bills';

    return AppTransaction(
      id: 'sms_${date.millisecondsSinceEpoch}',
      userId: userId,
      title: merchant,
      amount: -amount, // Expense
      type: TransactionType.expense,
      category: category,
      date: date,
      paymentMethod: 'UPI',
      subtitle: 'Auto-detected from SMS',
    );
  }
}

final smsParserService = SmsParserService();
