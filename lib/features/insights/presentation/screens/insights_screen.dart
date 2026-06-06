import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/core/widgets/glass_container.dart';
import 'package:finance_ai/features/insights/providers/insights_provider.dart';
import 'package:finance_ai/features/insights/presentation/widgets/budget_card.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(financialScoreProvider);
    final recommendationsAsync = ref.watch(aiRecommendationsProvider);
    final chartData = ref.watch(last6MonthsChartProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('AI Insights', style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.accent),
            onPressed: () => ref.invalidate(aiRecommendationsProvider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(AppDimensions.lg, 0, AppDimensions.lg, AppDimensions.bottomNavHeight + AppDimensions.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Financial Health Score ─────────────────────────
            GlassContainer(
              child: Column(
                children: [
                  Text('Financial Health Score', style: AppTextStyles.h2),
                  const SizedBox(height: AppDimensions.xxl),
                  SizedBox(
                    height: 180,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: score.score / 100),
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
                                Text('${(value * 100).toInt()}', style: AppTextStyles.displayLarge.copyWith(color: _scoreColor(value))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.xs),
                                  decoration: BoxDecoration(color: _scoreColor(value).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
                                  child: Text(_scoreGrade(value), style: AppTextStyles.label.copyWith(color: _scoreColor(value))),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xxl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSubScore('Savings', score.savingsScore, AppColors.income),
                      _buildSubScore('Debt', score.debtScore, AppColors.warning),
                      _buildSubScore('Invest', score.investScore, AppColors.primary),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.05),
            const SizedBox(height: AppDimensions.xxl),

            // ─── Spending Chart ───────────────────────────
            if (chartData.isNotEmpty) ...[
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
                          child: const Icon(Icons.bar_chart_rounded, color: AppColors.accent, size: 18),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Text('6-Month Spending', style: AppTextStyles.h3),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.xl),
                    SizedBox(
                      height: 100,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: chartData.map((d) {
                          final maxExpense = chartData.map((e) => e.expense).reduce(math.max);
                          final normalizedHeight = maxExpense > 0 ? d.expense / maxExpense : 0.0;
                          return _buildBar(d.month, normalizedHeight, AppColors.primary, isProjected: d.isProjected);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.05),
              const SizedBox(height: AppDimensions.xxl),
            ],

            // ─── Budgets ───────────────────────────
            Consumer(builder: (context, ref, _) {
              final budgets = ref.watch(budgetWithSpendingProvider);
              if (budgets.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Budgets', style: AppTextStyles.h3).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: AppDimensions.md),
                  ...budgets.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.md),
                    child: BudgetCard(budget: b).animate().fadeIn(delay: 450.ms).slideX(begin: -0.05),
                  )),
                  const SizedBox(height: AppDimensions.xl),
                ],
              );
            }),

            // ─── AI Recommendations ───────────────────────────────
            Text('AI Recommendations', style: AppTextStyles.h3).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: AppDimensions.md),
            recommendationsAsync.when(
              loading: () => Center(child: Padding(padding: const EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.primary))),
              error: (e, _) => Text('Error loading recommendations', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
              data: (tips) => Column(
                children: List.generate(tips.length, (i) {
                  final colors = [AppColors.income, AppColors.accent, AppColors.primary];
                  final icons = [Icons.lightbulb_outline_rounded, Icons.insights_rounded, Icons.trending_up_rounded];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.md),
                    child: _buildRecommendation(icons[i % icons.length], tips[i], '', colors[i % colors.length])
                        .animate().fadeIn(delay: Duration(milliseconds: 600 + (i * 100))).slideX(begin: 0.03),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppDimensions.xl),

            // ─── Anomaly Alerts ─────────────────────────────────
            if (score.anomalies.isNotEmpty) ...[
              Text('Anomaly Alerts', style: AppTextStyles.h3).animate().fadeIn(delay: 900.ms),
              const SizedBox(height: AppDimensions.md),
              ...score.anomalies.map((tx) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.md),
                child: GlassContainer(
                  borderColor: AppColors.warning.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
                        child: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: AppDimensions.iconMD),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Unusual Spend Detected', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warning)),
                            const SizedBox(height: 2),
                            Text('₹${tx.amount.abs().toStringAsFixed(0)} at ${tx.title} — higher than your average', style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1000.ms).shake(delay: 1200.ms, hz: 2, offset: const Offset(2, 0)),
              )),
            ],
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
                  CircularProgressIndicator(value: val, strokeWidth: 4, backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(color)),
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
                  height: 60 * val, // max height 60
                  decoration: BoxDecoration(
                    color: isProjected ? color.withValues(alpha: 0.4) : color,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    border: isProjected ? Border.all(color: color, width: 1) : null,
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
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
            child: Icon(icon, color: color, size: AppDimensions.iconSM),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(desc, style: AppTextStyles.caption),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreGaugePainter extends CustomPainter {
  final double progress;
  _ScoreGaugePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    const startAngle = 2.3;
    const sweepRange = math.pi * 1.4;

    final bgPaint = Paint()..color = AppColors.border..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepRange, false, bgPaint);

    if (progress > 0) {
      final progressPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          startAngle: 0.5, endAngle: 5.5,
          colors: [AppColors.error, AppColors.warning, AppColors.accent, AppColors.income],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepRange * progress, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreGaugePainter old) => old.progress != progress;
}
