import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';

class AddPortfolioItemScreen extends StatefulWidget {
  final String type; // 'investment', 'debt', 'asset', 'policy'

  const AddPortfolioItemScreen({super.key, required this.type});

  @override
  State<AddPortfolioItemScreen> createState() => _AddPortfolioItemScreenState();
}

class _AddPortfolioItemScreenState extends State<AddPortfolioItemScreen> {
  final _formKey = GlobalKey<FormState>();

  String get _title {
    switch (widget.type) {
      case 'investment': return 'Add Investment';
      case 'debt': return 'Add Debt Given';
      case 'asset': return 'Add Purchased Asset';
      case 'policy': return 'Add Policy';
      default: return 'Add Portfolio Item';
    }
  }

  Color get _themeColor {
    switch (widget.type) {
      case 'investment': return AppColors.primary;
      case 'debt': return AppColors.warning;
      case 'asset': return AppColors.accent;
      case 'policy': return AppColors.catInvestment;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_title, style: AppTextStyles.h2),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader().animate().fadeIn().slideY(begin: 0.1),
              const SizedBox(height: AppDimensions.xxl),
              ..._buildFormFields().animate(interval: 100.ms).fadeIn().slideX(begin: 0.05),
              const SizedBox(height: AppDimensions.xxl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: _buildSaveButton().animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: _themeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: _themeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForType(),
            color: _themeColor,
            size: 48,
          ),
          const SizedBox(width: AppDimensions.lg),
          Expanded(
            child: Text(
              'Keep track of your long-term wealth building progress.',
              style: AppTextStyles.bodyMedium.copyWith(color: _themeColor),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType() {
    switch (widget.type) {
      case 'investment': return Icons.trending_up_rounded;
      case 'debt': return Icons.handshake_rounded;
      case 'asset': return Icons.shopping_bag_rounded;
      case 'policy': return Icons.health_and_safety_rounded;
      default: return Icons.account_balance_rounded;
    }
  }

  List<Widget> _buildFormFields() {
    switch (widget.type) {
      case 'investment':
        return [
          _buildDropdown(
            label: 'Investment Type',
            items: ['Fixed Deposit', 'Recurring Deposit', 'Mutual Fund (SIP)', 'Stocks', 'Other'],
            value: 'Fixed Deposit',
          ),
          const SizedBox(height: AppDimensions.lg),
          _buildInput(label: 'Investment Name', hint: 'e.g., HDFC Fixed Deposit'),
          const SizedBox(height: AppDimensions.lg),
          Row(
            children: [
              Expanded(child: _buildInput(label: 'Amount (₹)', hint: '0.00', keyboardType: TextInputType.number)),
              const SizedBox(width: AppDimensions.lg),
              Expanded(child: _buildInput(label: 'Expected Return (%)', hint: '7.5', keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Frequency',
                  items: ['One-time', 'Monthly', 'Yearly'],
                  value: 'Monthly',
                ),
              ),
              const SizedBox(width: AppDimensions.lg),
              Expanded(child: _buildInput(label: 'Maturity Date', hint: 'DD/MM/YYYY')),
            ],
          ),
          const SizedBox(height: AppDimensions.xl),
          Text('Reminders & Notifications', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(child: _buildInput(label: 'Deduction Date (1-31)', hint: 'e.g., 5', keyboardType: TextInputType.number)),
              const SizedBox(width: AppDimensions.lg),
              Expanded(
                child: _buildDropdown(
                  label: 'Remind Me Before',
                  items: ['1 Day', '3 Days', '5 Days', '1 Week'],
                  value: '3 Days',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: AppDimensions.sm),
              Text('Push Notification', style: AppTextStyles.bodyMedium),
              const Spacer(),
              Switch(value: true, onChanged: (v) {}, activeColor: AppColors.primary),
            ],
          ),
          Row(
            children: [
              Icon(Icons.sms_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: AppDimensions.sm),
              Text('SMS Alert', style: AppTextStyles.bodyMedium),
              const Spacer(),
              Switch(value: true, onChanged: (v) {}, activeColor: AppColors.primary),
            ],
          ),
        ];
      case 'debt':
        return [
          _buildInput(label: 'Borrower Name', hint: 'e.g., Rahul Kumar'),
          const SizedBox(height: AppDimensions.lg),
          _buildInput(label: 'Amount Given (₹)', hint: '0.00', keyboardType: TextInputType.number),
          const SizedBox(height: AppDimensions.lg),
          _buildInput(label: 'Expected Return Date', hint: 'DD/MM/YYYY'),
        ];
      case 'asset':
        return [
          _buildInput(label: 'Asset Name', hint: 'e.g., MacBook Pro M3'),
          const SizedBox(height: AppDimensions.lg),
          _buildInput(label: 'Total Value (₹)', hint: '0.00', keyboardType: TextInputType.number),
          const SizedBox(height: AppDimensions.lg),
          Row(
            children: [
              Expanded(child: _buildInput(label: 'EMI Amount (₹)', hint: '0.00', keyboardType: TextInputType.number)),
              const SizedBox(width: AppDimensions.lg),
              Expanded(child: _buildInput(label: 'Total Months', hint: '12', keyboardType: TextInputType.number)),
            ],
          ),
        ];
      case 'policy':
        return [
          _buildDropdown(
            label: 'Policy Type',
            items: ['Life Insurance', 'Health Insurance', 'Vehicle Insurance', 'Other'],
            value: 'Life Insurance',
          ),
          const SizedBox(height: AppDimensions.lg),
          _buildInput(label: 'Policy Name', hint: 'e.g., LIC Jeevan Anand'),
          const SizedBox(height: AppDimensions.lg),
          Row(
            children: [
              Expanded(child: _buildInput(label: 'Sum Assured (₹)', hint: '0.00', keyboardType: TextInputType.number)),
              const SizedBox(width: AppDimensions.lg),
              Expanded(child: _buildInput(label: 'Premium (₹)', hint: '0.00', keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Frequency',
                  items: ['Monthly', 'Quarterly', 'Yearly'],
                  value: 'Yearly',
                ),
              ),
              const SizedBox(width: AppDimensions.lg),
              Expanded(child: _buildInput(label: 'Renewal Date', hint: 'DD/MM/YYYY')),
            ],
          ),
          const SizedBox(height: AppDimensions.xl),
          Text('Reminders & Notifications', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(child: _buildInput(label: 'Premium Date (1-31)', hint: 'e.g., 10', keyboardType: TextInputType.number)),
              const SizedBox(width: AppDimensions.lg),
              Expanded(
                child: _buildDropdown(
                  label: 'Remind Me Before',
                  items: ['1 Day', '3 Days', '5 Days', '1 Week'],
                  value: '5 Days',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Icon(Icons.notifications_active_rounded, color: AppColors.catInvestment, size: 20),
              const SizedBox(width: AppDimensions.sm),
              Text('Push Notification', style: AppTextStyles.bodyMedium),
              const Spacer(),
              Switch(value: true, onChanged: (v) {}, activeColor: AppColors.catInvestment),
            ],
          ),
          Row(
            children: [
              Icon(Icons.sms_rounded, color: AppColors.catInvestment, size: 20),
              const SizedBox(width: AppDimensions.sm),
              Text('SMS Alert', style: AppTextStyles.bodyMedium),
              const Spacer(),
              Switch(value: false, onChanged: (v) {}, activeColor: AppColors.catInvestment),
            ],
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildInput({required String label, required String hint, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppDimensions.sm),
        TextFormField(
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.all(AppDimensions.lg),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: BorderSide(color: _themeColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({required String label, required List<String> items, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppDimensions.sm),
        DropdownButtonFormField<String>(
          value: value,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
          style: AppTextStyles.bodyMedium,
          dropdownColor: AppColors.surface,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: AppTextStyles.bodyMedium),
            );
          }).toList(),
          onChanged: (val) {},
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.all(AppDimensions.lg),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: BorderSide(color: _themeColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      height: AppDimensions.buttonHeight,
      decoration: BoxDecoration(
        color: _themeColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [
          BoxShadow(
            color: _themeColor.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.heavyImpact();
          // Implement save logic here
          context.pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
        ),
        child: Text('Save ${_title.replaceAll('Add ', '')}', style: AppTextStyles.button.copyWith(color: Colors.white)),
      ),
    );
  }
}
