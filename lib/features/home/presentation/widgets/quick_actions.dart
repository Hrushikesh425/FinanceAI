import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 85,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _ActionButton(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scan',
            color: AppColors.accent,
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/scanner');
            },
          ),
          const SizedBox(width: AppDimensions.md),
          _ActionButton(
            icon: Icons.mic_rounded,
            label: 'Voice',
            color: AppColors.primary,
            onTap: () => HapticFeedback.lightImpact(),
          ),
          const SizedBox(width: AppDimensions.md),
          _ActionButton(
            icon: Icons.upload_file_rounded,
            label: 'Upload',
            color: AppColors.warning,
            onTap: () => HapticFeedback.lightImpact(),
          ),
          const SizedBox(width: AppDimensions.md),
          _ActionButton(
            icon: Icons.receipt_long_rounded,
            label: 'Receipt',
            color: AppColors.income,
            onTap: () => HapticFeedback.lightImpact(),
          ),
          const SizedBox(width: AppDimensions.md),
          _ActionButton(
            icon: Icons.share_rounded,
            label: 'Share',
            color: AppColors.info,
            onTap: () => HapticFeedback.lightImpact(),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 - _scaleController.value,
            child: SizedBox(
              width: 70,
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      border: Border.all(
                        color: widget.color.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: AppDimensions.iconMD,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    widget.label,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

