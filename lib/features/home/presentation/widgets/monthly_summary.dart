import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/core/widgets/glass_container.dart';
import 'package:finance_ai/core/widgets/animated_counter.dart';
import 'package:finance_ai/core/widgets/summary_card.dart';
import 'package:finance_ai/features/insights/providers/insights_provider.dart';
import 'package:finance_ai/features/home/providers/transaction_provider.dart';

class MonthlySummary extends ConsumerWidget {
  const MonthlySummary({super.key});

  String _formatCompact(double value) {
    if (value >= 100000) return '₹${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '₹${(value / 1000).toStringAsFixed(1)}K';
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(currentMonthStatsProvider);

    return statsAsync.when(
      loading: () => _buildShimmer(),
      error: (_, __) => _buildWithData(0, 0, 0, 0, {}),
      data: (stats) => _buildWithData(
        stats.totalIncome - stats.totalExpense,
        stats.totalIncome,
        stats.totalExpense,
        stats.savingsRate,
        stats.categorySpending,
      ),
    );
  }

  Widget _buildWithData(double balance, double income, double expense, double savingsRate, Map<String, double> categories) {
    final trend = savingsRate > 0 ? '+${savingsRate.toStringAsFixed(0)}%' : '${savingsRate.toStringAsFixed(0)}%';
    final isTrendPositive = savingsRate >= 0;
    final savings = income - expense;
    final upiSpend = categories.entries.where((e) => true).fold(0.0, (sum, _) => sum); // will be refined

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Balance Card
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text('This Month', style: AppTextStyles.body),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isTrendPositive ? AppColors.income : AppColors.expense).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(isTrendPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 14, color: isTrendPositive ? AppColors.income : AppColors.expense),
                    const SizedBox(width: 4),
                    Text(income > 0 ? 'Saved $trend' : 'No income yet', style: AppTextStyles.caption.copyWith(color: isTrendPositive ? AppColors.income : AppColors.expense, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
              const SizedBox(height: AppDimensions.sm),
              AnimatedCounter(value: balance.abs().toInt(), prefix: balance >= 0 ? '₹' : '-₹'),
              const SizedBox(height: AppDimensions.lg),
              Row(children: [
                _buildMiniStat('Income', _formatCompact(income), AppColors.income),
                const SizedBox(width: AppDimensions.lg),
                _buildMiniStat('Expenses', _formatCompact(expense), AppColors.expense),
                const SizedBox(width: AppDimensions.lg),
                _buildMiniStat('Savings', _formatCompact(savings > 0 ? savings : 0), AppColors.accent),
              ]),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.lg),

        // Horizontal Summary Cards — real data
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              SummaryCard(
                label: 'Food',
                amount: _formatCompact(categories['Food'] ?? 0),
                icon: Icons.restaurant_rounded,
                color: AppColors.catFood,
              ),
              const SizedBox(width: AppDimensions.md),
              SummaryCard(
                label: 'Shopping',
                amount: _formatCompact(categories['Shopping'] ?? 0),
                icon: Icons.shopping_bag_rounded,
                color: AppColors.catShopping,
              ),
              const SizedBox(width: AppDimensions.md),
              SummaryCard(
                label: 'Transport',
                amount: _formatCompact(categories['Transport'] ?? 0),
                icon: Icons.directions_car_rounded,
                color: AppColors.catTransport,
              ),
              const SizedBox(width: AppDimensions.md),
              SummaryCard(
                label: 'Bills',
                amount: _formatCompact(categories['Bills'] ?? 0),
                icon: Icons.receipt_rounded,
                color: AppColors.catBills,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 100, height: 14, decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: AppDimensions.md),
          Container(width: 180, height: 32, decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: AppDimensions.lg),
          Row(children: List.generate(3, (_) => Expanded(
            child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), height: 50, decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(8))),
          ))),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm, horizontal: AppDimensions.md),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
        child: Column(children: [
          Text(value, style: AppTextStyles.amountSmall.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ]),
      ),
    );
  }
}
