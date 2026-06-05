import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/core/widgets/glass_container.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmail(_emailController.text, _passwordController.text);
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

  Future<void> _handleGoogleSignIn() async {
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
  }

  void _handleBiometric() {
    HapticFeedback.heavyImpact();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppDimensions.xxl),

                    // ─── Logo with Glow ────────────────────────
                    _buildLogo()
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
                    const SizedBox(height: AppDimensions.lg),

                    // ─── App Name ──────────────────────────────
                    ShaderMask(
                      shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                      child: Text(
                        'FinanceAI',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2),
                    const SizedBox(height: AppDimensions.xs),

                    Text(
                      'Smart Finance, Zero Effort',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body,
                    ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

                    const SizedBox(height: AppDimensions.huge),

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
                    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideX(begin: -0.05),

                    const SizedBox(height: AppDimensions.lg),

                    // ─── Password Field ────────────────────────
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: AppDimensions.iconSM),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textMuted,
                            size: AppDimensions.iconSM,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                    ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideX(begin: -0.05),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot password?',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryLight),
                        ),
                      ),
                    ).animate().fadeIn(delay: 650.ms),

                    const SizedBox(height: AppDimensions.lg),

                    // ─── Login Button ──────────────────────────
                    _buildLoginButton()
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 400.ms)
                        .scale(begin: const Offset(0.95, 0.95)),

                    const SizedBox(height: AppDimensions.xxl),

                    // ─── Divider ───────────────────────────────
                    _buildDivider()
                        .animate().fadeIn(delay: 800.ms, duration: 400.ms),

                    const SizedBox(height: AppDimensions.xxl),

                    // ─── Social Buttons ────────────────────────
                    _buildGoogleButton()
                        .animate().fadeIn(delay: 900.ms, duration: 400.ms).slideY(begin: 0.1),
                    const SizedBox(height: AppDimensions.md),
                    _buildBiometricButton()
                        .animate().fadeIn(delay: 1000.ms, duration: 400.ms).slideY(begin: 0.1),

                    const SizedBox(height: AppDimensions.xxxl),

                    // ─── Sign Up Link ──────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: AppTextStyles.body),
                        GestureDetector(
                          onTap: () => context.push('/signup'),
                          child: Text(
                            'Sign Up',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 1100.ms),

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

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glowOpacity = 0.2 + (_pulseController.value * 0.15);
        return Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: glowOpacity),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              size: 44,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginButton() {
    return Container(
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
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text('Sign In', style: AppTextStyles.button),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
          child: Text('or continue with', style: AppTextStyles.caption),
        ),
        Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: AppDimensions.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: _handleGoogleSignIn,
        icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
        label: Text('Continue with Google', style: AppTextStyles.bodyMedium),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return SizedBox(
      height: AppDimensions.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: _handleBiometric,
        icon: Icon(Icons.fingerprint_rounded, size: 24, color: AppColors.accent),
        label: Text('Biometric Login', style: AppTextStyles.bodyMedium),
      ),
    );
  }
}


