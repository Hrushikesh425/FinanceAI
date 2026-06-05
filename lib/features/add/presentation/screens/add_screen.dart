import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/core/widgets/glass_container.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  bool _isExpense = true;
  String _selectedCategory = 'Food';
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  final _expenseCategories = [
    ('Food', Icons.restaurant_rounded, AppColors.catFood),
    ('Shopping', Icons.shopping_bag_rounded, AppColors.catShopping),
    ('Transport', Icons.directions_car_rounded, AppColors.catTransport),
    ('Bills', Icons.receipt_rounded, AppColors.catBills),
    ('Health', Icons.medical_services_rounded, AppColors.catHealth),
    ('Fun', Icons.movie_rounded, AppColors.catEntertainment),
    ('Education', Icons.school_rounded, AppColors.catEducation),
    ('Invest', Icons.trending_up_rounded, AppColors.catInvestment),
  ];

  final _quickAmounts = [100, 200, 500, 1000, 2000, 5000];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add Transaction', style: AppTextStyles.h2),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.lg, 0, AppDimensions.lg,
          AppDimensions.bottomNavHeight + AppDimensions.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Income / Expense Toggle ───────────────────────
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _buildToggle('Expense', _isExpense, () {
                    setState(() => _isExpense = true);
                    HapticFeedback.selectionClick();
                  }),
                  _buildToggle('Income', !_isExpense, () {
                    setState(() => _isExpense = false);
                    HapticFeedback.selectionClick();
                  }),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: AppDimensions.xxl),

            // ─── Amount Input ──────────────────────────────────
            GlassContainer(
              child: Column(
                children: [
                  Text('Enter Amount', style: AppTextStyles.body),
                  const SizedBox(height: AppDimensions.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('₹', style: AppTextStyles.displayMedium.copyWith(
                          color: AppColors.textMuted,
                        )),
                      ),
                      const SizedBox(width: 4),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displayLarge.copyWith(
                            color: _isExpense ? AppColors.expense : AppColors.income,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: '0',
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  // Quick amount buttons
                  Wrap(
                    spacing: AppDimensions.sm,
                    runSpacing: AppDimensions.sm,
                    alignment: WrapAlignment.center,
                    children: _quickAmounts.map((amt) {
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _amountController.text = amt.toString();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.md,
                            vertical: AppDimensions.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '₹$amt',
                            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.05),

            const SizedBox(height: AppDimensions.xxl),

            // ─── Category Grid ─────────────────────────────────
            Text('Category', style: AppTextStyles.h3)
                .animate().fadeIn(delay: 300.ms),
            const SizedBox(height: AppDimensions.md),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: AppDimensions.md,
                crossAxisSpacing: AppDimensions.md,
                childAspectRatio: 0.85,
              ),
              itemCount: _expenseCategories.length,
              itemBuilder: (context, i) {
                final cat = _expenseCategories[i];
                final isSelected = cat.$1 == _selectedCategory;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = cat.$1);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: AppDimensions.animFast),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cat.$3.withValues(alpha: 0.15)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      border: Border.all(
                        color: isSelected ? cat.$3 : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(cat.$2, color: cat.$3, size: AppDimensions.iconLG),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          cat.$1,
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected ? cat.$3 : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: 400 + (i * 40)),
                ).scale(begin: const Offset(0.9, 0.9));
              },
            ),

            const SizedBox(height: AppDimensions.xxl),

            // ─── Note ──────────────────────────────────────────
            TextFormField(
              controller: _noteController,
              style: AppTextStyles.bodyMedium,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                prefixIcon: Icon(Icons.note_alt_outlined, color: AppColors.textMuted, size: AppDimensions.iconSM),
              ),
            ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: AppDimensions.xxl),

            // ─── Action Buttons ────────────────────────────────
            Row(
              children: [
                // Voice input
                Container(
                  width: AppDimensions.buttonHeight,
                  height: AppDimensions.buttonHeight,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    onPressed: () => HapticFeedback.mediumImpact(),
                    icon: Icon(Icons.mic_rounded, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                // Camera
                Container(
                  width: AppDimensions.buttonHeight,
                  height: AppDimensions.buttonHeight,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    onPressed: () => HapticFeedback.mediumImpact(),
                    icon: Icon(Icons.camera_alt_rounded, color: AppColors.accent),
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                // Save button
                Expanded(
                  child: Container(
                    height: AppDimensions.buttonHeight,
                    decoration: BoxDecoration(
                      gradient: _isExpense
                          ? AppColors.expenseGradient
                          : AppColors.incomeGradient,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      boxShadow: [
                        BoxShadow(
                          color: (_isExpense ? AppColors.expense : AppColors.income)
                              .withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Transaction saved!'),
                            backgroundColor: AppColors.income,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      icon: const Icon(Icons.check_rounded, color: Colors.white),
                      label: Text('Save', style: AppTextStyles.button),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),

            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: AppDimensions.animFast),
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
          decoration: BoxDecoration(
            color: isActive
                ? (label == 'Expense' ? AppColors.expense : AppColors.income).withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isActive
                  ? (label == 'Expense' ? AppColors.expense : AppColors.income)
                  : AppColors.textMuted,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
