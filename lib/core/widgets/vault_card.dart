import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';

class VaultCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final int count;
  final String summary;
  final bool isExpanded;
  final ValueChanged<bool> onExpand;
  final Widget? child;

  const VaultCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.summary,
    required this.isExpanded,
    required this.onExpand,
    this.child,
  });

  @override
  State<VaultCard> createState() => _VaultCardState();
}

class _VaultCardState extends State<VaultCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: AppDimensions.animNormal),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );

    if (widget.isExpanded) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant VaultCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    widget.onExpand(!widget.isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            border: Border.all(
              color: widget.isExpanded
                  ? widget.iconColor.withValues(alpha: 0.3)
                  : AppColors.glassBorder,
              width: 1,
            ),
            boxShadow: widget.isExpanded
                ? [
                    BoxShadow(
                      color: widget.iconColor.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              // ─── Header ──────────────────────────────────────
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  onTap: _toggle,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    child: Row(
                      children: [
                        // Gradient icon container
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: widget.iconColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.iconColor,
                            size: AppDimensions.iconMD,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        // Title & summary
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.title, style: AppTextStyles.h3),
                              const SizedBox(height: 2),
                              Text(
                                widget.summary,
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        // Count badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm,
                            vertical: AppDimensions.xs,
                          ),
                          decoration: BoxDecoration(
                            color: widget.iconColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: Text(
                            '${widget.count}',
                            style: AppTextStyles.label.copyWith(color: widget.iconColor),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        // Animated arrow
                        RotationTransition(
                          turns: _rotateAnimation,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textMuted,
                            size: AppDimensions.iconMD,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Expandable Content ──────────────────────────
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Divider(
                        height: 1,
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.lg,
                          AppDimensions.sm,
                          AppDimensions.lg,
                          AppDimensions.lg,
                        ),
                        child: widget.child ?? const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

