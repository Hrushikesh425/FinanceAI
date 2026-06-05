import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/core/widgets/glass_container.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_ai/features/home/providers/transaction_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('AI Insights', style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.accent),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.lg, 0, AppDimensions.lg,
          AppDimensions.bottomNavHeight + AppDimensions.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Financial Health Score ─────────────────────────
            GlassContainer(
              child: Column(
                children: [
                  Text('Financial Health Score', style: AppTextStyles.h2),
                  const SizedBox(height: AppDimensions.xxl),
                  // Animated Gauge
                  SizedBox(
                    height: 180,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 0.78),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return CustomPaint(
                          size: const Size(180, 180),
                          painter: _ScoreGaugePainter(value),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(value * 100).toInt()}',
                                  style: AppTextStyles.displayLarge.copyWith(
                                    color: _scoreColor(value),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.md,
                                    vertical: AppDimensions.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _scoreColor(value).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                  ),
                                  child: Text(
                                    _scoreGrade(value),
                                    style: AppTextStyles.label.copyWith(color: _scoreColor(value)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xxl),
                  // Sub-scores
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSubScore('Savings', 82, AppColors.income),
                      _buildSubScore('Debt', 71, AppColors.warning),
                      _buildSubScore('Invest', 85, AppColors.primary),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.05),

            const SizedBox(height: AppDimensions.xxl),

            // ─── Spending Prediction ───────────────────────────
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                        ),
                        child: Icon(Icons.auto_graph_rounded, color: AppColors.accent, size: 18),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Text('Spending Prediction', style: AppTextStyles.h3),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  Text('Expected next month:', style: AppTextStyles.body),
                  const SizedBox(height: AppDimensions.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹45,200', style: AppTextStyles.amountLarge),
                      const SizedBox(width: AppDimensions.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm, vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.income.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_down_rounded, size: 14, color: AppColors.income),
                            const SizedBox(width: 2),
                            Text('-5%', style: AppTextStyles.caption.copyWith(
                              color: AppColors.income,
                              fontWeight: FontWeight.w600,
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  // Monthly bar chart
                  SizedBox(
                    height: 60,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBar('Jan', 0.6, AppColors.primary),
                        _buildBar('Feb', 0.75, AppColors.primary),
                        _buildBar('Mar', 0.5, AppColors.primary),
                        _buildBar('Apr', 0.8, AppColors.primary),
                        _buildBar('May', 0.7, AppColors.primary),
                        _buildBar('Jun', 0.65, AppColors.accent, isProjected: true),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.05),

            const SizedBox(height: AppDimensions.xxl),

            // ─── Recommendations ───────────────────────────────
            Text('Recommendations', style: AppTextStyles.h3)
                .animate().fadeIn(delay: 500.ms),
            const SizedBox(height: AppDimensions.md),
            _buildRecommendation(
              Icons.savings_rounded,
              'Increase savings by ₹5,000/month',
              'Your savings rate is 18%. Try to reach the recommended 20%.',
              AppColors.income,
            ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.03),
            const SizedBox(height: AppDimensions.md),
            _buildRecommendation(
              Icons.restaurant_rounded,
              'Cut food delivery by 15%',
              'You spent ₹5,620 on food delivery. Average is ₹4,800.',
              AppColors.catFood,
            ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.03),
            const SizedBox(height: AppDimensions.md),
            _buildRecommendation(
              Icons.trending_up_rounded,
              'Start a ₹2,000 SIP in index fund',
              'Based on your surplus, you can invest more efficiently.',
              AppColors.primary,
            ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.03),

            const SizedBox(height: AppDimensions.xxl),

            // ─── Anomaly Alert ─────────────────────────────────
            Text('Anomaly Alerts', style: AppTextStyles.h3)
                .animate().fadeIn(delay: 900.ms),
            const SizedBox(height: AppDimensions.md),
            GlassContainer(
              borderColor: AppColors.warning.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                    child: Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: AppDimensions.iconMD),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unusual Spend Detected', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warning)),
                        const SizedBox(height: 2),
                        Text('₹5,200 at Electronics Store — 3x your category average', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 1000.ms).shake(
              delay: 1200.ms,
              hz: 2,
              offset: const Offset(2, 0),
            ),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(double value) {
    if (value >= 0.8) return AppColors.income;
    if (value >= 0.6) return AppColors.accent;
    if (value >= 0.4) return AppColors.warning;
    return AppColors.error;
  }

  String _scoreGrade(double value) {
    if (value >= 0.9) return 'Excellent (A+)';
    if (value >= 0.8) return 'Great (A)';
    if (value >= 0.7) return 'Good (B+)';
    if (value >= 0.6) return 'Fair (C)';
    return 'Needs Work (D)';
  }

  Widget _buildSubScore(String label, int value, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 48, height: 48,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value / 100),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (_, val, __) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: val,
                    strokeWidth: 4,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                  Text('$value', style: AppTextStyles.label.copyWith(color: color)),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildBar(String label, double height, Color color, {bool isProjected = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: height),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (_, val, __) {
                return Container(
                  height: 40 * val,
                  decoration: BoxDecoration(
                    color: isProjected ? color.withValues(alpha: 0.4) : color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    border: isProjected
                        ? Border.all(color: color, width: 1)
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendation(IconData icon, String title, String desc, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Icon(icon, color: color, size: AppDimensions.iconSM),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 2),
                Text(desc, style: AppTextStyles.caption),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: AppDimensions.iconSM),
        ],
      ),
    );
  }
}

// Custom painter for the circular gauge
class _ScoreGaugePainter extends CustomPainter {
  final double progress;
  _ScoreGaugePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    const startAngle = 2.3; // radians
    const sweepRange = math.pi * 1.4;

    // Background arc
    final bgPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepRange,
      false,
      bgPaint,
    );

    // Progress arc with gradient
    if (progress > 0) {
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          startAngle: 0.5,
          endAngle: 5.5,
          colors: [
            AppColors.error,
            AppColors.warning,
            AppColors.accent,
            AppColors.income,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepRange * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreGaugePainter old) => old.progress != progress;
}
