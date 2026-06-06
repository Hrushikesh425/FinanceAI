import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/core/widgets/glass_container.dart';
import 'package:finance_ai/core/models/portfolio_item.dart';
import 'package:finance_ai/features/portfolio/providers/portfolio_provider.dart';
import 'package:finance_ai/core/services/push_notification_service.dart';

class AddPortfolioItemScreen extends ConsumerStatefulWidget {
  const AddPortfolioItemScreen({super.key});
  @override
  ConsumerState<AddPortfolioItemScreen> createState() => _AddPortfolioItemScreenState();
}

class _AddPortfolioItemScreenState extends ConsumerState<AddPortfolioItemScreen> {
  PortfolioType _selectedType = PortfolioType.investment;
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _interestRateController = TextEditingController();
  DateTime _nextPaymentDate = DateTime.now().add(const Duration(days: 30));
  bool _enableReminder = false;
  int _reminderDaysBefore = 1;
  bool _isSaving = false;

  final _types = [
    (PortfolioType.investment, 'Investment', Icons.trending_up_rounded, AppColors.primary),
    (PortfolioType.debt, 'Debt / EMI', Icons.money_off_rounded, AppColors.warning),
    (PortfolioType.asset, 'Asset', Icons.home_work_rounded, AppColors.accent),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextPaymentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _nextPaymentDate = picked);
  }

  Future<void> _save() async {
    final amountText = _amountController.text.trim();
    if (_nameController.text.trim().isEmpty || amountText.isEmpty || double.tryParse(amountText) == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid name and amount')));
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final amount = double.parse(amountText);
      final rateText = _interestRateController.text.trim();
      final rate = rateText.isNotEmpty ? double.tryParse(rateText) : null;

      final item = PortfolioItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _selectedType,
        amount: amount,
        interestRate: rate,
        nextPaymentDate: (_selectedType == PortfolioType.debt || _selectedType == PortfolioType.investment) ? _nextPaymentDate : null,
        reminderDaysBefore: _enableReminder ? _reminderDaysBefore : null,
      );

      final addFn = ref.read(addPortfolioItemProvider);
      await addFn(item);
      
      // Schedule Reminder
      if (_enableReminder && item.nextPaymentDate != null) {
        final reminderDate = item.nextPaymentDate!.subtract(Duration(days: _reminderDaysBefore));
        // Schedule it for 10 AM on the reminder day
        final scheduledTime = DateTime(reminderDate.year, reminderDate.month, reminderDate.day, 10, 0);
        
        await pushNotificationService.scheduleReminder(
          id: item.id.hashCode,
          title: '${_selectedType == PortfolioType.debt ? 'Payment Due:' : 'Investment Reminder:'} ${item.name}',
          body: 'Amount: ₹${item.amount.toStringAsFixed(0)} is due in $_reminderDaysBefore days.',
          scheduledDate: scheduledTime,
        );
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Add Portfolio Item', style: AppTextStyles.h2)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Types
            Row(
              children: _types.map((t) => Expanded(
                child: GestureDetector(
                  onTap: () { HapticFeedback.selectionClick(); setState(() => _selectedType = t.$1); },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                    decoration: BoxDecoration(
                      color: _selectedType == t.$1 ? t.$4.withValues(alpha: 0.15) : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      border: Border.all(color: _selectedType == t.$1 ? t.$4 : AppColors.border),
                    ),
                    child: Column(children: [
                      Icon(t.$3, color: _selectedType == t.$1 ? t.$4 : AppColors.textMuted),
                      const SizedBox(height: 4),
                      Text(t.$2, style: AppTextStyles.caption.copyWith(color: _selectedType == t.$1 ? t.$4 : AppColors.textSecondary)),
                    ]),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: AppDimensions.xxl),

            // Form
            GlassContainer(
              child: Column(children: [
                TextFormField(
                  controller: _nameController,
                  style: AppTextStyles.bodyMedium,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Name (e.g. Home Loan, HDFC Mutual Fund)'),
                ),
                const SizedBox(height: AppDimensions.lg),
                TextFormField(
                  controller: _amountController,
                  style: AppTextStyles.bodyMedium,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (₹)', prefixIcon: Icon(Icons.currency_rupee_rounded)),
                ),
                const SizedBox(height: AppDimensions.lg),
                TextFormField(
                  controller: _interestRateController,
                  style: AppTextStyles.bodyMedium,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Interest Rate % (Optional)', prefixIcon: Icon(Icons.percent_rounded)),
                ),
              ]),
            ),
            const SizedBox(height: AppDimensions.xxl),

            // Reminders (Only for debt/investment)
            if (_selectedType != PortfolioType.asset) ...[
              Text('Schedule & Reminders', style: AppTextStyles.h3),
              const SizedBox(height: AppDimensions.md),
              GlassContainer(
                child: Column(children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Next Payment Date'),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(_nextPaymentDate)),
                    trailing: const Icon(Icons.calendar_today_rounded),
                    onTap: _pickDate,
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable Push Reminder'),
                    value: _enableReminder,
                    onChanged: (v) => setState(() => _enableReminder = v),
                    activeColor: AppColors.primary,
                  ),
                  if (_enableReminder) ...[
                    const SizedBox(height: AppDimensions.md),
                    Row(children: [
                      const Text('Remind me '),
                      DropdownButton<int>(
                        value: _reminderDaysBefore,
                        dropdownColor: AppColors.cardBg,
                        items: [1, 2, 3, 5, 7].map((d) => DropdownMenuItem(value: d, child: Text('$d days'))).toList(),
                        onChanged: (v) { if (v != null) setState(() => _reminderDaysBefore = v); },
                      ),
                      const Text(' before due date'),
                    ]),
                  ]
                ]),
              ),
              const SizedBox(height: AppDimensions.xxl),
            ],

            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save to Portfolio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
