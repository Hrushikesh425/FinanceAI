import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/core/widgets/compact_card.dart';
import 'package:finance_ai/core/widgets/glass_container.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_ai/core/models/portfolio_item.dart';
import '../providers/portfolio_provider.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
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
                  Text('My Portfolio', style: AppTextStyles.h2),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

            // Portfolio Net Worth Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
              child: GlassContainer(
                borderColor: AppColors.primary.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(AppDimensions.xl),
                child: Column(
                  children: [
                    Text('Total Net Worth', style: AppTextStyles.body),
                    const SizedBox(height: AppDimensions.xs),
                    Text('₹5,42,000', style: AppTextStyles.h1),
                    const SizedBox(height: AppDimensions.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem('Assets', '₹6,02,000', AppColors.income),
                        Container(height: 30, width: 1, color: AppColors.divider),
                        _buildSummaryItem('Liabilities', '₹60,000', AppColors.error),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

            const SizedBox(height: AppDimensions.lg),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.center,
                indicator: BoxDecoration(
                  color: AppColors.cardBgLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: AppTextStyles.button,
                unselectedLabelStyle: AppTextStyles.button,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Investments'),
                  Tab(text: 'Debts'),
                  Tab(text: 'Assets'),
                  Tab(text: 'Policies'),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: AppDimensions.md),

            // Tab Views
            Expanded(
              child: ref.watch(portfolioProvider).when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, st) => Center(child: Text('Error: $e', style: AppTextStyles.body)),
                data: (items) {
                  final investments = items.where((i) => i.type == PortfolioItemType.investment).toList();
                  final debts = items.where((i) => i.type == PortfolioItemType.debt).toList();
                  final assets = items.where((i) => i.type == PortfolioItemType.asset).toList();
                  final policies = items.where((i) => i.type == PortfolioItemType.policy).toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInvestmentsTab(investments),
                      _buildDebtsTab(debts),
                      _buildAssetsTab(assets),
                      _buildPoliciesTab(policies),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.h3.copyWith(color: color)),
      ],
    );
  }

  // ─── TABS ─────────────────────────────────────────────────────────────

  Widget _buildInvestmentsTab(List<PortfolioItem> items) {
    if (items.isEmpty) return _buildMockInvestmentsTab();
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, 0, AppDimensions.lg, 100),
      children: [
        _buildAddButton('Investment', Icons.trending_up_rounded, AppColors.primary, 'investment'),
        const SizedBox(height: AppDimensions.lg),
        ...items.map((i) => CompactCard(
          title: i.name,
          subtitle: '${i.subType} • ${i.frequency}',
          amount: i.amount,
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.primary,
        )),
      ],
    );
  }

  Widget _buildMockInvestmentsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, 0, AppDimensions.lg, 100),
      children: [
        _buildAddButton('Investment', Icons.trending_up_rounded, AppColors.primary, 'investment'),
        const SizedBox(height: AppDimensions.lg),
        const CompactCard(
          title: 'HDFC Fixed Deposit',
          subtitle: 'Matures in 2 mos • 7.1% p.a.',
          amount: 150000,
          icon: Icons.account_balance_rounded,
          iconColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildDebtsTab(List<PortfolioItem> items) {
    if (items.isEmpty) return _buildMockDebtsTab();
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, 0, AppDimensions.lg, 100),
      children: [
        _buildAddButton('Debt Given', Icons.handshake_rounded, AppColors.warning, 'debt'),
        const SizedBox(height: AppDimensions.lg),
        ...items.map((i) => CompactCard(
          title: i.name,
          subtitle: 'Expected return',
          amount: i.amount,
          icon: Icons.person_rounded,
          iconColor: AppColors.warning,
        )),
      ],
    );
  }

  Widget _buildMockDebtsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, 0, AppDimensions.lg, 100),
      children: [
        _buildAddButton('Debt Given', Icons.handshake_rounded, AppColors.warning, 'debt'),
        const SizedBox(height: AppDimensions.lg),
        const CompactCard(
          title: 'Rahul Kumar',
          subtitle: 'Expected next week',
          amount: 25000,
          icon: Icons.person_rounded,
          iconColor: AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildAssetsTab(List<PortfolioItem> items) {
    if (items.isEmpty) return _buildMockAssetsTab();
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, 0, AppDimensions.lg, 100),
      children: [
        _buildAddButton('Asset / Loan', Icons.shopping_bag_rounded, AppColors.accent, 'asset'),
        const SizedBox(height: AppDimensions.lg),
        ...items.map((i) => CompactCard(
          title: i.name,
          subtitle: '${i.secondaryAmount}/mo EMI',
          amount: i.amount,
          icon: Icons.laptop_mac_rounded,
          iconColor: AppColors.error,
        )),
      ],
    );
  }

  Widget _buildMockAssetsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, 0, AppDimensions.lg, 100),
      children: [
        _buildAddButton('Asset / Loan', Icons.shopping_bag_rounded, AppColors.accent, 'asset'),
        const SizedBox(height: AppDimensions.lg),
        const CompactCard(
          title: 'MacBook Pro M3',
          subtitle: '6/12 EMIs paid • ₹4,500/mo',
          amount: -27000,
          icon: Icons.laptop_mac_rounded,
          iconColor: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildPoliciesTab(List<PortfolioItem> items) {
    if (items.isEmpty) return _buildMockPoliciesTab();
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, 0, AppDimensions.lg, 100),
      children: [
        _buildAddButton('Policy', Icons.health_and_safety_rounded, AppColors.catInvestment, 'policy'),
        const SizedBox(height: AppDimensions.lg),
        ...items.map((i) => CompactCard(
          title: i.name,
          subtitle: 'Premium: ₹${i.secondaryAmount}',
          amount: i.amount,
          icon: Icons.security_rounded,
          iconColor: AppColors.catInvestment,
        )),
      ],
    );
  }

  Widget _buildMockPoliciesTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, 0, AppDimensions.lg, 100),
      children: [
        _buildAddButton('Policy', Icons.health_and_safety_rounded, AppColors.catInvestment, 'policy'),
        const SizedBox(height: AppDimensions.lg),
        const CompactCard(
          title: 'LIC Jeevan Anand',
          subtitle: 'Due in 45 days • ₹12,000/yr',
          amount: 500000, // Sum assured
          icon: Icons.security_rounded,
          iconColor: AppColors.catInvestment,
        ),
      ],
    );
  }

  Widget _buildAddButton(String typeName, IconData icon, Color color, String routeParam) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        // We will pass the type to the add screen
        context.push('/portfolio/add?type=$routeParam');
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, color: color),
            const SizedBox(width: AppDimensions.sm),
            Text('Add New $typeName', style: AppTextStyles.button.copyWith(color: color)),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }
}
