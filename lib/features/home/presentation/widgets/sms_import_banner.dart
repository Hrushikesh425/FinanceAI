import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/core/widgets/glass_container.dart';
import 'package:finance_ai/core/models/transaction.dart';
import 'package:finance_ai/core/services/sms_parser_service.dart';
import 'package:finance_ai/features/auth/providers/auth_provider.dart';
import 'package:finance_ai/features/home/providers/transaction_provider.dart';

class SmsImportBanner extends ConsumerStatefulWidget {
  const SmsImportBanner({super.key});

  @override
  ConsumerState<SmsImportBanner> createState() => _SmsImportBannerState();
}

class _SmsImportBannerState extends ConsumerState<SmsImportBanner> {
  bool _isLoading = true;
  List<AppTransaction> _pendingTransactions = [];

  @override
  void initState() {
    super.initState();
    _checkForSms();
  }

  Future<void> _checkForSms() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    
    final txs = await smsParserService.extractRecentUpiTransactions(user.uid);
    if (mounted) {
      setState(() {
        _pendingTransactions = txs;
        _isLoading = false;
      });
    }
  }

  Future<void> _importAll() async {
    if (_pendingTransactions.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      final addTx = ref.read(addTransactionProvider);
      for (final tx in _pendingTransactions) {
        // give each a unique ID so they don't overwrite if timestamps match exactly
        final newTx = AppTransaction(
          id: '${tx.id}_${DateTime.now().microsecondsSinceEpoch}',
          userId: tx.userId,
          title: tx.title,
          subtitle: tx.subtitle,
          amount: tx.amount,
          type: tx.type,
          category: tx.category,
          date: tx.date,
          paymentMethod: tx.paymentMethod,
          receiptImageUrl: tx.receiptImageUrl,
        );
        await addTx(newTx);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Imported ${_pendingTransactions.length} transactions successfully!'),
          backgroundColor: AppColors.income,
        ));
        setState(() {
          _pendingTransactions = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error importing: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink(); // Hide while checking
    if (_pendingTransactions.isEmpty) return const SizedBox.shrink(); // Hide if nothing found

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.xxl),
      child: GlassContainer(
        borderColor: AppColors.primary.withValues(alpha: 0.3),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: const Icon(Icons.mark_email_unread_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_pendingTransactions.length} UPI Payments Found', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 2),
                  Text('Auto-detected from SMS', style: AppTextStyles.caption),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _importAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 0),
                minimumSize: const Size(0, 36),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
              ),
              child: const Text('Import'),
            ),
          ],
        ),
      ),
    );
  }
}
