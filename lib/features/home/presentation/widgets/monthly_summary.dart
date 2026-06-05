import 'package:flutter/material.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/core/widgets/glass_container.dart';
import 'package:finance_ai/core/widgets/animated_counter.dart';
import 'package:finance_ai/core/widgets/summary_card.dart';

class MonthlySummary extends StatelessWidget {
  const MonthlySummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Hero Balance Card ─────────────────────────────────
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Total Balance', style: AppTextStyles.body),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.income.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up_rounded, size: 14, color: AppColors.income),
                        const SizedBox(width: 4),
                        Text('+12%', style: AppTextStyles.caption.copyWith(
                          color: AppColors.income,
                          fontWeight: FontWeight.w600,
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),
              const AnimatedCounter(
                value: 247500,
                prefix: '₹',
              ),
              const SizedBox(height: AppDimensions.lg),
              // Mini stats row
              Row(
                children: [
                  _buildMiniStat('Income', '₹85K', AppColors.income),
                  const SizedBox(width: AppDimensions.lg),
                  _buildMiniStat('Expenses', '₹42K', AppColors.expense),
                  const SizedBox(width: AppDimensions.lg),
                  _buildMiniStat('Savings', '₹43K', AppColors.accent),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.lg),

        // ─── Horizontal Summary Cards ──────────────────────────
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: const [
              SummaryCard(
                label: 'Investments',
                amount: '₹3.2L',
                icon: Icons.trending_up_rounded,
                color: AppColors.primary,
                trend: '+8%',
                isTrendPositive: true,
              ),
              SizedBox(width: AppDimensions.md),
              SummaryCard(
                label: 'UPI Spend',
                amount: '₹12.4K',
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.accent,
                trend: '+3%',
                isTrendPositive: false,
              ),
              SizedBox(width: AppDimensions.md),
              SummaryCard(
                label: 'EMIs',
                amount: '₹5.2K',
                icon: Icons.calendar_month_rounded,
                color: AppColors.warning,
                trend: '0%',
                isTrendPositive: true,
              ),
              SizedBox(width: AppDimensions.md),
              SummaryCard(
                label: 'Debts',
                amount: '₹45K',
                icon: Icons.handshake_rounded,
                color: AppColors.error,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm, horizontal: AppDimensions.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.amountSmall.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
