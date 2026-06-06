import 'package:flutter/material.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/core/widgets/glass_container.dart';
import 'package:finance_ai/core/models/budget.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  
  const BudgetCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    Color progressColor = AppColors.primary;
    if (budget.isOverLimit) progressColor = AppColors.error;
    else if (budget.isNearLimit) progressColor = AppColors.warning;

    return GlassContainer(
      borderColor: budget.isOverLimit ? AppColors.error.withValues(alpha: 0.3) : AppColors.glassBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(budget.category, style: AppTextStyles.h3),
              Text('₹${budget.spent.toStringAsFixed(0)} / ₹${budget.monthlyLimit.toStringAsFixed(0)}', style: AppTextStyles.bodyMedium),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: budget.percentUsed,
              backgroundColor: AppColors.surfaceLight,
              color: progressColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          if (budget.isOverLimit)
            Text('Over budget by ₹${(budget.spent - budget.monthlyLimit).toStringAsFixed(0)}', style: AppTextStyles.caption.copyWith(color: AppColors.error))
          else
            Text('₹${budget.remaining.toStringAsFixed(0)} remaining', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
