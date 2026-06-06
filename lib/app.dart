import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_ai/core/theme/app_theme.dart';
import 'package:finance_ai/core/router/app_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:finance_ai/core/services/local_auth_service.dart';
import 'package:finance_ai/core/constants/app_colors.dart';

class FinanceAIApp extends ConsumerStatefulWidget {
  const FinanceAIApp({super.key});
  @override
  ConsumerState<FinanceAIApp> createState() => _FinanceAIAppState();
}

class _FinanceAIAppState extends ConsumerState<FinanceAIApp> with WidgetsBindingObserver {
  bool _isLocked = false;
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthService();
  DateTime? _lastPausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLockOnStart();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkLockOnStart() async {
    final enabled = await _storage.read(key: 'biometric_enabled');
    if (enabled == 'true') {
      setState(() => _isLocked = true);
      _authenticate();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lastPausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_lastPausedTime != null) {
        final diff = DateTime.now().difference(_lastPausedTime!);
        // Lock if backgrounded for more than 30 seconds
        if (diff.inSeconds > 30) {
          _checkLockOnStart();
        }
      }
    }
  }

  Future<void> _authenticate() async {
    final success = await _localAuth.authenticate();
    if (success && mounted) {
      setState(() => _isLocked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FinanceAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            if (_isLocked)
              Positioned.fill(
                child: Container(
                  color: AppColors.background,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_rounded, size: 64, color: AppColors.primary),
                        const SizedBox(height: 24),
                        Text('App Locked', style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 48),
                        ElevatedButton.icon(
                          onPressed: _authenticate,
                          icon: const Icon(Icons.fingerprint_rounded),
                          label: const Text('Unlock'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
