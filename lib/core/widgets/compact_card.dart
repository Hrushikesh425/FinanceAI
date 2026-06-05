import 'package:flutter/material.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';

class CompactCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const CompactCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIncome = amount >= 0;
    final Color amountColor = isIncome ? AppColors.income : AppColors.expense;
    final String amountText = isIncome
        ? '+₹${_formatAmount(amount.abs())}'
        : '-₹${_formatAmount(amount.abs())}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        splashColor: iconColor.withValues(alpha: 0.1),
        highlightColor: iconColor.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.md,
            horizontal: AppDimensions.sm,
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Icon(icon, color: iconColor, size: AppDimensions.iconSM),
              ),
              const SizedBox(width: AppDimensions.md),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.sm),

              // Amount
              Text(
                amountText,
                style: AppTextStyles.amountSmall.copyWith(color: amountColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(double value) {
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
    }
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  }
}
