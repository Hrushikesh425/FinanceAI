import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/core/widgets/glass_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
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
          children: [
            // ─── Profile Header ────────────────────────────────
            GlassContainer(
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: AppDimensions.avatarXL,
                    height: AppDimensions.avatarXL,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGlow,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'H',
                        style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  Text('Hrushikesh', style: AppTextStyles.h1),
                  const SizedBox(height: AppDimensions.xs),
                  Text('hrush@example.com', style: AppTextStyles.body),
                  const SizedBox(height: AppDimensions.lg),

                  // Stats row
                  Row(
                    children: [
                      _buildStat('Transactions', '156'),
                      _buildVerticalDivider(),
                      _buildStat('Months', '8'),
                      _buildVerticalDivider(),
                      _buildStat('Score', '78'),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.lg),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/edit-profile'),
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Edit Profile'),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05),

            const SizedBox(height: AppDimensions.xxl),

            // ─── Security Settings ─────────────────────────────
            _buildSectionTitle('Security')
                .animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppDimensions.md),
            _buildSettingsGroup([
              _SettingItem(Icons.lock_rounded, 'Change Password', onTap: () {}),
              _SettingItem(Icons.fingerprint_rounded, 'Biometric Login', isSwitch: true, switchValue: true),
              _SettingItem(Icons.security_rounded, 'Two-Factor Auth', isSwitch: true, switchValue: false),
            ]).animate().fadeIn(delay: 300.ms).slideY(begin: 0.03),

            const SizedBox(height: AppDimensions.xxl),

            // ─── Preferences ───────────────────────────────────
            _buildSectionTitle('Preferences')
                .animate().fadeIn(delay: 400.ms),
            const SizedBox(height: AppDimensions.md),
            _buildSettingsGroup([
              _SettingItem(Icons.notifications_rounded, 'Notifications', trailing: 'On'),
              _SettingItem(Icons.palette_rounded, 'Theme', trailing: 'Dark'),
              _SettingItem(Icons.language_rounded, 'Language', trailing: 'English'),
              _SettingItem(Icons.currency_rupee_rounded, 'Currency', trailing: '₹ INR'),
            ]).animate().fadeIn(delay: 500.ms).slideY(begin: 0.03),

            const SizedBox(height: AppDimensions.xxl),

            // ─── Data ──────────────────────────────────────────
            _buildSectionTitle('Data')
                .animate().fadeIn(delay: 600.ms),
            const SizedBox(height: AppDimensions.md),
            _buildSettingsGroup([
              _SettingItem(Icons.download_rounded, 'Export Data', onTap: () {}),
              _SettingItem(Icons.backup_rounded, 'Backup to Cloud', onTap: () {}),
              _SettingItem(Icons.delete_forever_rounded, 'Delete Account', color: AppColors.error, onTap: () {}),
            ]).animate().fadeIn(delay: 700.ms).slideY(begin: 0.03),

            const SizedBox(height: AppDimensions.xxl),

            // ─── Logout ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _showLogoutDialog(context);
                },
                icon: Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                label: Text(
                  'Logout',
                  style: AppTextStyles.button.copyWith(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 800.ms),

            const SizedBox(height: AppDimensions.lg),
            Text('Version 1.0.0', style: AppTextStyles.caption)
                .animate().fadeIn(delay: 900.ms),
            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.border,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: AppTextStyles.h3),
    );
  }

  Widget _buildSettingsGroup(List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: item.color ?? AppColors.textSecondary, size: AppDimensions.iconMD),
                title: Text(item.title, style: AppTextStyles.bodyMedium.copyWith(
                  color: item.color ?? AppColors.textPrimary,
                )),
                trailing: item.isSwitch
                    ? Switch(
                        value: item.switchValue ?? false,
                        onChanged: (v) {},
                      )
                    : item.trailing != null
                        ? Text(item.trailing!, style: AppTextStyles.bodySmall)
                        : Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: AppDimensions.iconSM),
                onTap: item.isSwitch ? null : item.onTap,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.lg,
                  vertical: AppDimensions.xs,
                ),
              ),
              if (i < items.length - 1)
                Divider(
                  height: 1,
                  color: AppColors.divider,
                  indent: AppDimensions.lg + AppDimensions.iconMD + AppDimensions.lg,
                ),
            ],
          );
        }),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          side: BorderSide(color: AppColors.glassBorder),
        ),
        title: Text('Logout', style: AppTextStyles.h2),
        content: Text('Are you sure you want to logout?', style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Logout', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String? trailing;
  final bool isSwitch;
  final bool? switchValue;
  final Color? color;
  final VoidCallback? onTap;

  _SettingItem(
    this.icon,
    this.title, {
    this.trailing,
    this.isSwitch = false,
    this.switchValue,
    this.color,
    this.onTap,
  });
}
