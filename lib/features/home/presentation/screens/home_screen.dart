import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/core/widgets/custom_app_bar.dart';
import 'package:finance_ai/core/widgets/vault_card.dart';
import 'package:finance_ai/core/widgets/compact_card.dart';
import 'package:finance_ai/core/widgets/glass_container.dart';
import 'package:finance_ai/core/models/transaction.dart';
import 'package:finance_ai/features/home/providers/transaction_provider.dart';
import 'package:finance_ai/features/auth/providers/auth_provider.dart';
import 'package:finance_ai/features/home/presentation/widgets/monthly_summary.dart';
import 'package:finance_ai/features/home/presentation/widgets/quick_actions.dart';
import 'package:finance_ai/features/home/presentation/widgets/sms_import_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _expandedVaultIndex = -1;

  void _handleVaultExpand(int index, bool isExpanded) {
    setState(() => _expandedVaultIndex = isExpanded ? index : -1);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️ Good Morning';
    if (hour < 17) return '🌤️ Good Afternoon';
    return '🌙 Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final userName = authService.currentUserName;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomAppBar(
            username: userName,
            greeting: _getGreeting(),
            notificationCount: 0,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.cardBg,
              onRefresh: () async {
                ref.invalidate(transactionsProvider);
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(AppDimensions.lg, 0, AppDimensions.lg, AppDimensions.bottomNavHeight + AppDimensions.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MonthlySummary().animate().fadeIn(duration: 500.ms).slideY(begin: 0.05),
                    const SizedBox(height: AppDimensions.xxl),
                    const SmsImportBanner(),
                    Text('Quick Actions', style: AppTextStyles.h3).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: AppDimensions.md),
                    const QuickActions().animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: AppDimensions.xxl),
                    _buildPortfolioLink(context).animate().fadeIn(delay: 350.ms),
                    const SizedBox(height: AppDimensions.xxl),
                    Text('Recent Transactions', style: AppTextStyles.h3).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: AppDimensions.md),
                    _buildTransactionsList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioLink(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); context.go('/portfolio'); },
      child: GlassContainer(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
            child: const Icon(Icons.pie_chart_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('My Portfolio', style: AppTextStyles.h3),
            Text('Manage Investments, Debts & Assets', style: AppTextStyles.bodySmall),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 16),
        ]),
      ),
    );
  }

  Widget _buildTransactionsList() {
    final asyncTransactions = ref.watch(transactionsProvider);

    return asyncTransactions.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary))),
      error: (e, st) => GlassContainer(
        child: Column(children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 40),
          const SizedBox(height: AppDimensions.md),
          Text('Unable to load transactions', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppDimensions.sm),
          Text('$e', style: AppTextStyles.caption, textAlign: TextAlign.center),
        ]),
      ),
      data: (transactions) {
        if (transactions.isEmpty) {
          return GlassContainer(
            child: Column(children: [
              const SizedBox(height: AppDimensions.lg),
              Icon(Icons.receipt_long_rounded, color: AppColors.textMuted.withValues(alpha: 0.5), size: 48),
              const SizedBox(height: AppDimensions.md),
              Text('No transactions yet', style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppDimensions.sm),
              Text('Tap + to add your first expense or income', style: AppTextStyles.body, textAlign: TextAlign.center),
              const SizedBox(height: AppDimensions.lg),
            ]),
          ).animate().fadeIn(delay: 500.ms);
        }

        // Group by date
        final Map<String, List<AppTransaction>> grouped = {};
        for (final tx in transactions.take(50)) {
          final key = _formatDateKey(tx.date);
          grouped.putIfAbsent(key, () => []).add(tx);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: grouped.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.md, bottom: AppDimensions.sm),
                  child: Text(entry.key, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                ),
                ...entry.value.map((tx) => Dismissible(
                  key: ValueKey(tx.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: AppDimensions.lg),
                    margin: const EdgeInsets.only(bottom: AppDimensions.sm),
                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.cardBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.glassBorder)),
                      title: Text('Delete Transaction', style: AppTextStyles.h3),
                      content: Text('Delete "${tx.title}" (₹${tx.amount.abs().toStringAsFixed(0)})?', style: AppTextStyles.body),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          child: const Text('Delete'),
                        ),
                      ],
                    ));
                  },
                  onDismissed: (_) {
                    final user = ref.read(authStateProvider).value;
                    if (user != null) {
                      final fs = ref.read(firestoreServiceProvider);
                      fs.deleteTransaction(user.uid, tx.id);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                    child: CompactCard(
                      title: tx.title,
                      subtitle: '${tx.category} • ${tx.paymentMethod}',
                      amount: tx.amount,
                      icon: tx.icon,
                      iconColor: tx.type == TransactionType.income ? AppColors.income : AppColors.expense,
                    ),
                  ),
                )),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDate = DateTime(date.year, date.month, date.day);
    if (txDate == today) return 'Today';
    if (txDate == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (now.difference(date).inDays < 7) return DateFormat('EEEE').format(date);
    return DateFormat('d MMMM yyyy').format(date);
  }
}
