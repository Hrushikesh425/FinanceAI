import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/core/widgets/custom_app_bar.dart';
import 'package:finance_ai/core/widgets/vault_card.dart';
import 'package:finance_ai/core/widgets/compact_card.dart';
import 'package:finance_ai/core/widgets/glass_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_ai/core/models/transaction.dart';
import 'package:finance_ai/features/home/providers/transaction_provider.dart';
import 'package:finance_ai/features/home/presentation/widgets/monthly_summary.dart';
import 'package:finance_ai/features/home/presentation/widgets/quick_actions.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _expandedVaultIndex = -1;

  void _handleVaultExpand(int index, bool isExpanded) {
    setState(() {
      _expandedVaultIndex = isExpanded ? index : -1;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️ Good Morning';
    if (hour < 17) return '🌤️ Good Afternoon';
    return '🌙 Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // App bar
          CustomAppBar(
            username: 'Hrushikesh',
            greeting: _getGreeting(),
            notificationCount: 3,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.lg,
                0,
                AppDimensions.lg,
                AppDimensions.bottomNavHeight + AppDimensions.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Monthly summary
                  const MonthlySummary()
                      .animate().fadeIn(duration: 500.ms).slideY(begin: 0.05),

                  const SizedBox(height: AppDimensions.xxl),

                  // Quick Actions
                  Text('Quick Actions', style: AppTextStyles.h3)
                      .animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: AppDimensions.md),
                  const QuickActions()
                      .animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: AppDimensions.xxl),
                  
                  // Link to Portfolio
                  _buildPortfolioLink(context).animate().fadeIn(delay: 350.ms),

                  const SizedBox(height: AppDimensions.xxl),

                  // Daily Vaults
                  Text('Daily Tracking', style: AppTextStyles.h3)
                      .animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: AppDimensions.md),

                  _buildVaultsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioLink(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Index 2 is the new Portfolio branch in the shell
        // We can't directly context.go to a shell branch without the shell handling it,
        // but /portfolio is the path!
        context.go('/portfolio');
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: const Icon(Icons.pie_chart_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Portfolio', style: AppTextStyles.h3),
                  Text('Manage Investments, Debts & Assets', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildVaultsList() {
    final asyncTransactions = ref.watch(transactionsProvider);

    return asyncTransactions.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, st) => Center(child: Text('Error loading transactions: $e', style: AppTextStyles.body)),
      data: (transactions) {
        if (transactions.isEmpty) {
          // Fallback to mock if empty (just to keep UI beautiful while testing)
          return _buildMockVaults();
        }

        // Group actual transactions
        final upiTx = transactions.where((t) => t.paymentMethod == 'UPI').toList();
        final otherTx = transactions.where((t) => t.paymentMethod != 'UPI').toList();

        final vaults = [
          _VaultData('UPI & Bank', Icons.account_balance_wallet_rounded, AppColors.accent, upiTx.length, '${upiTx.length} items', upiTx),
          _VaultData('Other Transactions', Icons.receipt_long_rounded, const Color(0xFF26A69A), otherTx.length, '${otherTx.length} items', otherTx),
        ];

        return _buildVaultsColumn(vaults);
      },
    );
  }

  Widget _buildMockVaults() {
    final mockVaults = [
      _VaultData('UPI & GPay', Icons.account_balance_wallet_rounded, AppColors.accent, 3, '₹12,450 this month', [
        AppTransaction(id: '1', userId: '1', title: 'Swiggy', amount: -345, type: TransactionType.expense, category: 'Food', date: DateTime.now(), paymentMethod: 'UPI'),
        AppTransaction(id: '2', userId: '1', title: 'Amazon India', amount: -1299, type: TransactionType.expense, category: 'Shopping', date: DateTime.now(), paymentMethod: 'UPI'),
        AppTransaction(id: '3', userId: '1', title: 'Rent Transfer', amount: -15000, type: TransactionType.expense, category: 'Housing', date: DateTime.now(), paymentMethod: 'Bank Transfer'),
      ]),
    ];
    return _buildVaultsColumn(mockVaults);
  }

  Widget _buildVaultsColumn(List<_VaultData> vaults) {
    return Column(
      children: List.generate(vaults.length, (i) {
        final v = vaults[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.md),
          child: VaultCard(
            title: v.title,
            icon: v.icon,
            iconColor: v.color,
            count: v.count,
            summary: v.summary,
            isExpanded: _expandedVaultIndex == i,
            onExpand: (expanded) => _handleVaultExpand(i, expanded),
            child: Column(
              children: v.items.map((tx) => CompactCard(
                title: tx.title,
                subtitle: tx.category,
                amount: tx.amount,
                icon: tx.icon,
                iconColor: v.color,
              )).toList(),
            ),
          ).animate().fadeIn(
            delay: Duration(milliseconds: 500 + (i * AppDimensions.staggerDelay)),
            duration: const Duration(milliseconds: AppDimensions.animNormal),
          ).slideY(begin: 0.05),
        );
      }),
    );
  }
}

class _VaultData {
  final String title;
  final IconData icon;
  final Color color;
  final int count;
  final String summary;
  final List<AppTransaction> items;
  _VaultData(this.title, this.icon, this.color, this.count, this.summary, this.items);
}
