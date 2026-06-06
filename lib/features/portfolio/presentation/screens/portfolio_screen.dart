import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/core/widgets/glass_container.dart';
import 'package:finance_ai/core/models/portfolio_item.dart';
import 'package:finance_ai/features/portfolio/providers/portfolio_provider.dart';
import 'package:finance_ai/features/auth/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(portfolioProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Portfolio', style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
            onPressed: () => context.push('/add-portfolio'),
          ),
        ],
      ),
      body: portfolioAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error))),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_outline_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: AppDimensions.md),
                  Text('Your portfolio is empty', style: AppTextStyles.h3),
                  const SizedBox(height: AppDimensions.sm),
                  Text('Add investments, debts, and assets to track your net worth.', style: AppTextStyles.body, textAlign: TextAlign.center),
                  const SizedBox(height: AppDimensions.xl),
                  ElevatedButton(
                    onPressed: () => context.push('/add-portfolio'),
                    child: const Text('Add Item'),
                  ),
                ],
              ),
            );
          }

          double totalInvested = 0;
          double totalDebt = 0;
          double totalAssets = 0;

          for (final item in items) {
            if (item.type == PortfolioType.investment) totalInvested += item.amount;
            if (item.type == PortfolioType.debt) totalDebt += item.amount;
            if (item.type == PortfolioType.asset) totalAssets += item.amount;
          }

          final netWorth = totalInvested + totalAssets - totalDebt;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(AppDimensions.lg, 0, AppDimensions.lg, AppDimensions.bottomNavHeight + AppDimensions.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Net Worth Summary
                GlassContainer(
                  child: Column(
                    children: [
                      Text('Net Worth', style: AppTextStyles.body),
                      const SizedBox(height: AppDimensions.sm),
                      Text('₹${netWorth.toStringAsFixed(0)}', style: AppTextStyles.displayMedium.copyWith(color: netWorth >= 0 ? AppColors.income : AppColors.error)),
                      const SizedBox(height: AppDimensions.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem('Assets', totalAssets, AppColors.accent),
                          _buildSummaryItem('Invested', totalInvested, AppColors.primary),
                          _buildSummaryItem('Debt', totalDebt, AppColors.warning),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.xxl),

                // Item List
                ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.md),
                  child: Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: AppDimensions.lg),
                      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
                      child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.cardBg,
                        title: Text('Delete ${item.name}?', style: AppTextStyles.h3),
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
                        ref.read(firestoreServiceProvider).deletePortfolioItem(user.uid, item.id);
                      }
                    },
                    child: GlassContainer(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: _getColor(item.type).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                            child: Icon(_getIcon(item.type), color: _getColor(item.type)),
                          ),
                          const SizedBox(width: AppDimensions.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: AppTextStyles.bodyMedium),
                                if (item.interestRate != null || item.nextPaymentDate != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    [
                                      if (item.interestRate != null) '${item.interestRate}%',
                                      if (item.nextPaymentDate != null) 'Next: ${DateFormat('dd MMM').format(item.nextPaymentDate!)}'
                                    ].join(' • '),
                                    style: AppTextStyles.caption,
                                  ),
                                ]
                              ],
                            ),
                          ),
                          Text('₹${item.amount.toStringAsFixed(0)}', style: AppTextStyles.h3),
                        ],
                      ),
                    ),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text('₹${amount.toStringAsFixed(0)}', style: AppTextStyles.bodyMedium.copyWith(color: color)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Color _getColor(PortfolioType type) {
    switch (type) {
      case PortfolioType.investment: return AppColors.primary;
      case PortfolioType.debt: return AppColors.warning;
      case PortfolioType.asset: return AppColors.accent;
    }
  }

  IconData _getIcon(PortfolioType type) {
    switch (type) {
      case PortfolioType.investment: return Icons.trending_up_rounded;
      case PortfolioType.debt: return Icons.money_off_rounded;
      case PortfolioType.asset: return Icons.home_work_rounded;
    }
  }
}
