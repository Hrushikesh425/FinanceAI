import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/core/widgets/glass_container.dart';
import 'package:finance_ai/core/widgets/compact_card.dart';

class UpiScreen extends StatefulWidget {
  const UpiScreen({super.key});

  @override
  State<UpiScreen> createState() => _UpiScreenState();
}

class _UpiScreenState extends State<UpiScreen> {
  String _selectedFilter = 'All';
  final _filters = ['All', 'GPay', 'PhonePe', 'Paytm', 'This Week'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('UPI & GPay', style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
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
            // ─── Spending Overview ─────────────────────────────
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total UPI Spend', style: AppTextStyles.body),
                            const SizedBox(height: AppDimensions.xs),
                            Text('₹12,450', style: AppTextStyles.amountLarge),
                            const SizedBox(height: AppDimensions.xs),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.sm, vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.expense.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.trending_up_rounded, size: 12, color: AppColors.expense),
                                      const SizedBox(width: 2),
                                      Text('+8% vs last month', style: AppTextStyles.caption.copyWith(
                                        color: AppColors.expense,
                                        fontWeight: FontWeight.w600,
                                      )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Mini pie chart
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 20,
                            sections: [
                              PieChartSectionData(
                                value: 45, color: AppColors.catFood,
                                radius: 16, showTitle: false,
                              ),
                              PieChartSectionData(
                                value: 25, color: AppColors.catShopping,
                                radius: 16, showTitle: false,
                              ),
                              PieChartSectionData(
                                value: 20, color: AppColors.catBills,
                                radius: 16, showTitle: false,
                              ),
                              PieChartSectionData(
                                value: 10, color: AppColors.catEntertainment,
                                radius: 16, showTitle: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05),

            const SizedBox(height: AppDimensions.lg),

            // ─── Filter Chips ──────────────────────────────────
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.sm),
                itemBuilder: (context, i) {
                  final isSelected = _filters[i] == _selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = _filters[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: AppDimensions.animFast),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.lg,
                        vertical: AppDimensions.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        _filters[i],
                        style: AppTextStyles.label.copyWith(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: AppDimensions.xxl),

            // ─── Category Breakdown ────────────────────────────
            Text('Category Breakdown', style: AppTextStyles.h3)
                .animate().fadeIn(delay: 300.ms),
            const SizedBox(height: AppDimensions.md),
            _buildCategoryBreakdown()
                .animate().fadeIn(delay: 400.ms),

            const SizedBox(height: AppDimensions.xxl),

            // ─── Recent Transactions ───────────────────────────
            Text('Recent Transactions', style: AppTextStyles.h3)
                .animate().fadeIn(delay: 500.ms),
            const SizedBox(height: AppDimensions.md),
            ..._buildTransactionList(),

            const SizedBox(height: AppDimensions.xxl),

            // ─── Spending Insights ─────────────────────────────
            GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: AppDimensions.iconSM),
                      const SizedBox(width: AppDimensions.sm),
                      Text('AI Insights', style: AppTextStyles.h3),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.md),
                  _buildInsightRow(Icons.fastfood_rounded, 'Food delivery is 23% higher than last month', AppColors.catFood),
                  const SizedBox(height: AppDimensions.md),
                  _buildInsightRow(Icons.home_rounded, 'Rent is your largest expense at 45%', AppColors.catBills),
                  const SizedBox(height: AppDimensions.md),
                  _buildInsightRow(Icons.savings_rounded, 'You saved ₹3,200 compared to last month', AppColors.income),
                ],
              ),
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final categories = [
      ('Food', '₹5,620', AppColors.catFood, 0.45),
      ('Shopping', '₹3,100', AppColors.catShopping, 0.25),
      ('Bills', '₹2,480', AppColors.catBills, 0.20),
      ('Fun', '₹1,250', AppColors.catEntertainment, 0.10),
    ];

    return Column(
      children: categories.map((cat) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.md),
          child: Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: cat.$3, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                flex: 2,
                child: Text(cat.$1, style: AppTextStyles.bodySmall),
              ),
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: cat.$4),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, val, __) {
                      return LinearProgressIndicator(
                        value: val,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(cat.$3),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              SizedBox(
                width: 55,
                child: Text(cat.$2, style: AppTextStyles.amountSmall, textAlign: TextAlign.right),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildTransactionList() {
    final txns = [
      ('Swiggy', 'Today • Food', -345.0, Icons.restaurant_rounded, AppColors.catFood),
      ('Amazon', 'Yesterday • Shopping', -1299.0, Icons.shopping_bag_rounded, AppColors.catShopping),
      ('Netflix', 'May 28 • Entertainment', -649.0, Icons.movie_rounded, const Color(0xFFE50914)),
      ('Rent', 'May 1 • Housing', -15000.0, Icons.home_rounded, AppColors.catBills),
      ('Salary Received', 'May 1 • Income', 85000.0, Icons.business_center_rounded, AppColors.income),
    ];

    return List.generate(txns.length, (i) {
      final tx = txns[i];
      return CompactCard(
        title: tx.$1,
        subtitle: tx.$2,
        amount: tx.$3,
        icon: tx.$4,
        iconColor: tx.$5,
      ).animate().fadeIn(
        delay: Duration(milliseconds: 600 + (i * AppDimensions.staggerDelay)),
      ).slideX(begin: 0.03);
    });
  }

  Widget _buildInsightRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
      ],
    );
  }
}
