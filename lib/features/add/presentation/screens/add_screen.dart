import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/core/widgets/glass_container.dart';
import 'package:finance_ai/core/models/transaction.dart';
import 'package:finance_ai/features/home/providers/transaction_provider.dart';
import 'package:finance_ai/features/auth/providers/auth_provider.dart';

class AddScreen extends ConsumerStatefulWidget {
  final AppTransaction? prefilled; // For scanner pre-fill
  const AddScreen({super.key, this.prefilled});
  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  bool _isExpense = true;
  String _selectedCategory = 'Food';
  String _selectedPaymentMethod = 'UPI';
  DateTime _selectedDate = DateTime.now();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSaving = false;

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

  final _incomeCategories = [
    ('Salary', Icons.account_balance_wallet_rounded, AppColors.income),
    ('Freelance', Icons.laptop_rounded, AppColors.accent),
    ('Interest', Icons.savings_rounded, AppColors.primary),
    ('Gift', Icons.card_giftcard_rounded, AppColors.catEntertainment),
    ('Refund', Icons.replay_rounded, AppColors.catTransport),
    ('Other', Icons.more_horiz_rounded, AppColors.textMuted),
  ];

  final _paymentMethods = ['UPI', 'Cash', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Wallet'];
  final _quickAmounts = [100, 200, 500, 1000, 2000, 5000];

  @override
  void initState() {
    super.initState();
    if (widget.prefilled != null) {
      _amountController.text = widget.prefilled!.amount.abs().toStringAsFixed(0);
      _noteController.text = widget.prefilled!.title;
      _selectedCategory = widget.prefilled!.category;
      _selectedPaymentMethod = widget.prefilled!.paymentMethod;
      _selectedDate = widget.prefilled!.date;
      _isExpense = widget.prefilled!.type == TransactionType.expense;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<(String, IconData, Color)> get _activeCategories => _isExpense ? _expenseCategories : _incomeCategories;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(primary: AppColors.primary, surface: AppColors.cardBg),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveTransaction() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty || double.tryParse(amountText) == null || double.parse(amountText) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please enter a valid amount'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please sign in first'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final amount = double.parse(amountText);
      final tx = AppTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        title: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : _selectedCategory,
        amount: _isExpense ? -amount.abs() : amount.abs(),
        type: _isExpense ? TransactionType.expense : TransactionType.income,
        category: _selectedCategory,
        date: _selectedDate,
        paymentMethod: _selectedPaymentMethod,
      );

      final addFn = ref.read(addTransactionProvider);
      await addFn(tx);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${_isExpense ? "Expense" : "Income"} of ₹${amount.toStringAsFixed(0)} saved!'),
          backgroundColor: AppColors.income,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Add Transaction', style: AppTextStyles.h2)),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(AppDimensions.lg, 0, AppDimensions.lg, AppDimensions.bottomNavHeight + AppDimensions.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income / Expense Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                _buildToggle('Expense', _isExpense, () { setState(() { _isExpense = true; _selectedCategory = 'Food'; }); HapticFeedback.selectionClick(); }),
                _buildToggle('Income', !_isExpense, () { setState(() { _isExpense = false; _selectedCategory = 'Salary'; }); HapticFeedback.selectionClick(); }),
              ]),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: AppDimensions.xxl),

            // Amount Input
            GlassContainer(
              child: Column(children: [
                Text('Enter Amount', style: AppTextStyles.body),
                const SizedBox(height: AppDimensions.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: const EdgeInsets.only(top: 8), child: Text('₹', style: AppTextStyles.displayMedium.copyWith(color: AppColors.textMuted))),
                    const SizedBox(width: 4),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayLarge.copyWith(color: _isExpense ? AppColors.expense : AppColors.income),
                        decoration: const InputDecoration(border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, hintText: '0', contentPadding: EdgeInsets.zero, isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.lg),
                Wrap(
                  spacing: AppDimensions.sm, runSpacing: AppDimensions.sm, alignment: WrapAlignment.center,
                  children: _quickAmounts.map((amt) => GestureDetector(
                    onTap: () { HapticFeedback.selectionClick(); _amountController.text = amt.toString(); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
                      decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(AppDimensions.radiusFull), border: Border.all(color: AppColors.border)),
                      child: Text('₹$amt', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                    ),
                  )).toList(),
                ),
              ]),
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.05),
            const SizedBox(height: AppDimensions.xxl),

            // Date & Payment Method row
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: GlassContainer(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: AppDimensions.sm),
                      Text(DateFormat('dd MMM yyyy').format(_selectedDate), style: AppTextStyles.bodyMedium),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPaymentMethod,
                      dropdownColor: AppColors.cardBg,
                      style: AppTextStyles.bodyMedium,
                      isExpanded: true,
                      items: _paymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (v) { if (v != null) setState(() => _selectedPaymentMethod = v); },
                    ),
                  ),
                ),
              ),
            ]).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: AppDimensions.xxl),

            // Category Grid
            Text('Category', style: AppTextStyles.h3).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: AppDimensions.md),
            GridView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: AppDimensions.md, crossAxisSpacing: AppDimensions.md, childAspectRatio: 0.85),
              itemCount: _activeCategories.length,
              itemBuilder: (context, i) {
                final cat = _activeCategories[i];
                final isSelected = cat.$1 == _selectedCategory;
                return GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); setState(() => _selectedCategory = cat.$1); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: AppDimensions.animFast),
                    decoration: BoxDecoration(
                      color: isSelected ? cat.$3.withValues(alpha: 0.15) : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      border: Border.all(color: isSelected ? cat.$3 : AppColors.border, width: isSelected ? 1.5 : 1),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(cat.$2, color: cat.$3, size: AppDimensions.iconLG),
                      const SizedBox(height: AppDimensions.sm),
                      Text(cat.$1, style: AppTextStyles.caption.copyWith(color: isSelected ? cat.$3 : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400), textAlign: TextAlign.center),
                    ]),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 400 + (i * 40))).scale(begin: const Offset(0.9, 0.9));
              },
            ),
            const SizedBox(height: AppDimensions.xxl),

            // Note
            TextFormField(
              controller: _noteController, style: AppTextStyles.bodyMedium, maxLines: 2,
              decoration: InputDecoration(hintText: 'Add a note (optional)', prefixIcon: Icon(Icons.note_alt_outlined, color: AppColors.textMuted, size: AppDimensions.iconSM)),
            ).animate().fadeIn(delay: 700.ms),
            const SizedBox(height: AppDimensions.xxl),

            // Save Button
            Row(children: [
              // Camera shortcut
              Container(
                width: AppDimensions.buttonHeight, height: AppDimensions.buttonHeight,
                decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(AppDimensions.radiusMD), border: Border.all(color: AppColors.border)),
                child: IconButton(
                  onPressed: () => context.push('/scanner'),
                  icon: const Icon(Icons.camera_alt_rounded, color: AppColors.accent),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              // Save button
              Expanded(
                child: Container(
                  height: AppDimensions.buttonHeight,
                  decoration: BoxDecoration(
                    gradient: _isExpense ? AppColors.expenseGradient : AppColors.incomeGradient,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    boxShadow: [BoxShadow(color: (_isExpense ? AppColors.expense : AppColors.income).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveTransaction,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                    icon: _isSaving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_rounded, color: Colors.white),
                    label: Text(_isSaving ? 'Saving...' : 'Save', style: AppTextStyles.button),
                  ),
                ),
              ),
            ]).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
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
            color: isActive ? (label == 'Expense' ? AppColors.expense : AppColors.income).withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
          child: Text(label, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium.copyWith(
            color: isActive ? (label == 'Expense' ? AppColors.expense : AppColors.income) : AppColors.textMuted,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          )),
        ),
      ),
    );
  }
}
