import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isSaving = false;
  final _nameController = TextEditingController(text: 'Hrushikesh');
  final _emailController = TextEditingController(text: 'hrush@example.com');
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  final _incomeController = TextEditingController(text: '85000');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _save() {
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: AppColors.income,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
          ),
        );
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTextStyles.h2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          children: [
            // ─── Avatar ────────────────────────────────────────
            Center(
              child: Stack(
                children: [
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
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text('H', style: AppTextStyles.displayMedium.copyWith(color: Colors.white)),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),

            const SizedBox(height: AppDimensions.xxxl),

            // ─── Form Fields ───────────────────────────────────
            _buildField('Full Name', _nameController, Icons.person_outline_rounded)
                .animate().fadeIn(delay: 200.ms).slideX(begin: -0.03),
            const SizedBox(height: AppDimensions.lg),
            _buildField('Email', _emailController, Icons.email_outlined, keyboard: TextInputType.emailAddress)
                .animate().fadeIn(delay: 300.ms).slideX(begin: -0.03),
            const SizedBox(height: AppDimensions.lg),
            _buildField('Phone', _phoneController, Icons.phone_outlined, keyboard: TextInputType.phone)
                .animate().fadeIn(delay: 400.ms).slideX(begin: -0.03),
            const SizedBox(height: AppDimensions.lg),
            _buildField('Monthly Income (₹)', _incomeController, Icons.currency_rupee_rounded, keyboard: TextInputType.number)
                .animate().fadeIn(delay: 500.ms).slideX(begin: -0.03),

            const SizedBox(height: AppDimensions.xxxl),

            // ─── Save Button ───────────────────────────────────
            Container(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryGlow, blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text('Save Changes', style: AppTextStyles.button),
              ),
            ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.95, 0.95)),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboard}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppDimensions.sm),
        TextFormField(
          controller: controller,
          style: AppTextStyles.bodyMedium,
          keyboardType: keyboard,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: AppDimensions.iconSM),
          ),
        ),
      ],
    );
  }
}
