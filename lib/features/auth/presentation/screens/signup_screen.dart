import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  double _passwordStrength = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 6) strength += 0.25;
    if (password.length >= 10) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9!@#$%^&*]'))) strength += 0.25;
    setState(() => _passwordStrength = strength);
  }

  Color get _strengthColor {
    if (_passwordStrength <= 0.25) return AppColors.error;
    if (_passwordStrength <= 0.5) return AppColors.warning;
    if (_passwordStrength <= 0.75) return AppColors.info;
    return AppColors.success;
  }

  String get _strengthLabel {
    if (_passwordStrength <= 0.25) return 'Weak';
    if (_passwordStrength <= 0.5) return 'Fair';
    if (_passwordStrength <= 0.75) return 'Good';
    return 'Strong';
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signUpWithEmail(_emailController.text, _passwordController.text);
      if (mounted) context.go('/home');
    } catch (e) {
      debugPrint('Auth Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Firebase not configured yet. Bypassing for UI testing.'),
            backgroundColor: AppColors.warning,
            duration: Duration(seconds: 2),
          ),
        );
        context.go('/home');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppDimensions.xxl),

                    // ─── Header ────────────────────────────────
                    Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h1,
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'Start your smart financial journey',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body,
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: AppDimensions.xxxl),

                    // ─── Name Field ────────────────────────────
                    TextFormField(
                      controller: _nameController,
                      style: AppTextStyles.bodyMedium,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textMuted, size: AppDimensions.iconSM),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter your name' : null,
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.05),

                    const SizedBox(height: AppDimensions.lg),

                    // ─── Email Field ───────────────────────────
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted, size: AppDimensions.iconSM),
                      ),
                      validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.05),

                    const SizedBox(height: AppDimensions.lg),

                    // ─── Password Field ────────────────────────
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: AppTextStyles.bodyMedium,
                      onChanged: _updatePasswordStrength,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: AppDimensions.iconSM),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textMuted, size: AppDimensions.iconSM,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.05),

                    // Password strength bar
                    if (_passwordController.text.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.sm),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: _passwordStrength),
                                duration: const Duration(milliseconds: 300),
                                builder: (context, value, _) {
                                  return LinearProgressIndicator(
                                    value: value,
                                    minHeight: 4,
                                    backgroundColor: AppColors.border,
                                    valueColor: AlwaysStoppedAnimation(_strengthColor),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          Text(
                            _strengthLabel,
                            style: AppTextStyles.caption.copyWith(color: _strengthColor),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: AppDimensions.lg),

                    // ─── Confirm Password ──────────────────────
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: AppDimensions.iconSM),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textMuted, size: AppDimensions.iconSM,
                          ),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (v) => v != _passwordController.text ? 'Passwords don\'t match' : null,
                    ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.05),

                    const SizedBox(height: AppDimensions.xxl),

                    // ─── Sign Up Button ────────────────────────
                    Container(
                      height: AppDimensions.buttonHeight,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGlow,
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : Text('Create Account', style: AppTextStyles.button),
                      ),
                    ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.95, 0.95)),

                    const SizedBox(height: AppDimensions.xxl),

                    // ─── Google Sign-Up ────────────────────────
                    SizedBox(
                      height: AppDimensions.buttonHeight,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          HapticFeedback.mediumImpact();
                          setState(() => _isLoading = true);
                          try {
                            final authService = ref.read(authServiceProvider);
                            await authService.signInWithGoogle();
                            if (mounted) context.go('/home');
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Google Sign-In bypassed for UI testing.'), backgroundColor: AppColors.warning),
                              );
                              context.go('/home');
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                        label: Text('Sign up with Google', style: AppTextStyles.bodyMedium),
                      ),
                    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),

                    const SizedBox(height: AppDimensions.xxxl),

                    // ─── Login Link ────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ', style: AppTextStyles.body),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            'Sign In',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryLight),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 900.ms),

                    const SizedBox(height: AppDimensions.xxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
