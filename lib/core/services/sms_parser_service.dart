import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:finance_ai/core/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmsParserService {
  // Platform channel to read SMS via native Android ContentProvider
  static const _channel = MethodChannel('com.hrushikesh.financeai/sms');

  // Regex for Indian UPI/Bank SMS formats
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

      final prefs = await SharedPreferences.getInstance();
      final lastCheckTime = prefs.getInt('last_sms_check_time') ??
          DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch;

      // Read SMS from native Android via platform channel
      List<Map<String, dynamic>> messages = [];
      try {
        final result = await _channel.invokeMethod<List>('getInboxSms', {
          'count': 50,
          'afterTimestamp': lastCheckTime,
        });
        if (result != null) {
          messages = result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      } on MissingPluginException {
        // Platform channel not implemented yet — return empty gracefully
        debugPrint('SMS platform channel not implemented');
        return [];
      } on PlatformException catch (e) {
        debugPrint('SMS platform channel error: ${e.message}');
        return [];
      }

      final newTransactions = <AppTransaction>[];
      final currentCheckTime = DateTime.now().millisecondsSinceEpoch;

      for (final msg in messages) {
        final body = (msg['body'] as String?) ?? '';
        final sender = (msg['sender'] as String?) ?? '';
        final timestamp = (msg['timestamp'] as int?) ?? 0;

        if (body.isEmpty || timestamp <= lastCheckTime) continue;

        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final lowerBody = body.toLowerCase();

        // Only process banking/UPI senders
        if (!sender.contains(RegExp(r'\d')) &&
            (lowerBody.contains('debited') ||
                lowerBody.contains('sent ') ||
                lowerBody.contains('paid '))) {
          final tx = _parseMessage(body, date, userId);
          if (tx != null) newTransactions.add(tx);
        }
      }

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

    for (final regex in _debitRegexes) {
      final match = regex.firstMatch(body);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '');
        amount = double.tryParse(amountStr ?? '');
        break;
      }
    }

    if (amount == null) return null;

    for (final regex in _merchantRegexes) {
      final match = regex.firstMatch(body);
      if (match != null) {
        merchant = match.group(1)?.trim();
        if (merchant == 'your' || merchant == 'a/c' || merchant == 'account') {
          merchant = null;
          continue;
        }
        break;
      }
    }

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
      amount: -amount,
      type: TransactionType.expense,
      category: category,
      date: date,
      paymentMethod: 'UPI',
      subtitle: 'Auto-detected from SMS',
    );
  }
}

final smsParserService = SmsParserService();
