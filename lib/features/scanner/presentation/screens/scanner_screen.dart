import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/core/widgets/glass_container.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_ai/core/models/transaction.dart';
import 'package:finance_ai/features/auth/providers/auth_provider.dart';
import 'package:finance_ai/features/home/providers/transaction_provider.dart';
import 'package:finance_ai/features/scanner/providers/scanner_provider.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> with TickerProviderStateMixin {
  late AnimationController _scanLineController;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  bool _isProcessing = false;
  AppTransaction? _parsedResult;

  void _simulateScan() async {
    HapticFeedback.heavyImpact();
    setState(() => _isProcessing = true);

    // Simulate ML Kit OCR extraction delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate extracted text
    const mockExtractedText = '''
    RELIANCE FRESH
    Koramangala, Bangalore
    Date: 03 Jun 2026
    Milk: 60.00
    Bread: 40.00
    TOTAL: 100.00
    ''';

    final userId = ref.read(authStateProvider).value?.uid ?? 'temp-user';
    final scannerService = ref.read(aiScannerServiceProvider);

    try {
      final result = await scannerService.parseReceiptText(mockExtractedText, userId);
      if (mounted) {
        setState(() {
          _parsedResult = result ?? AppTransaction(
            id: 'mock', userId: userId, title: 'Reliance Fresh', 
            amount: -100, type: TransactionType.expense, 
            category: 'Groceries', date: DateTime.now(), paymentMethod: 'Scanner'
          );
          _hasScanned = true;
          _isProcessing = false;
        });
        _scanLineController.stop();
      }
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Scan Receipt', style: AppTextStyles.h2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // ─── Camera Viewfinder ───────────────────────────────
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                child: Stack(
                  children: [
                    // Placeholder for camera
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.textMuted),
                          const SizedBox(height: AppDimensions.lg),
                          Text(
                            _hasScanned ? 'Receipt Scanned!' : 'Point camera at receipt',
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                    ),

                    // Scanning line animation
                    if (!_hasScanned)
                      AnimatedBuilder(
                        animation: _scanLineController,
                        builder: (context, _) {
                          return Positioned(
                            top: _scanLineController.value * 280 + 20,
                            left: 20,
                            right: 20,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.accent.withValues(alpha: 0.8),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentGlow,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    // Corner markers
                    _buildCorner(Alignment.topLeft),
                    _buildCorner(Alignment.topRight),
                    _buildCorner(Alignment.bottomLeft),
                    _buildCorner(Alignment.bottomRight),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),
          ),

          // ─── Results or Actions ──────────────────────────────
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: _hasScanned ? _buildResults() : _buildActions(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    final isTop = alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft = alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    return Positioned(
      top: isTop ? 16 : null,
      bottom: !isTop ? 16 : null,
      left: isLeft ? 16 : null,
      right: !isLeft ? 16 : null,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? BorderSide(color: AppColors.accent, width: 3) : BorderSide.none,
            bottom: !isTop ? BorderSide(color: AppColors.accent, width: 3) : BorderSide.none,
            left: isLeft ? BorderSide(color: AppColors.accent, width: 3) : BorderSide.none,
            right: !isLeft ? BorderSide(color: AppColors.accent, width: 3) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        Text('Scan your receipts or bills', style: AppTextStyles.h3),
        const SizedBox(height: AppDimensions.sm),
        Text(
          'AI will automatically extract the amount,\ndate, and merchant from your receipt',
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        Row(
          children: [
            // Upload from gallery
            Expanded(
              child: SizedBox(
                height: AppDimensions.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: () => HapticFeedback.lightImpact(),
                  icon: const Icon(Icons.photo_library_rounded, size: 20),
                  label: const Text('Gallery'),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            // Capture
            Expanded(
              child: Container(
                height: AppDimensions.buttonHeight,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryGlow, blurRadius: 12),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _simulateScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  icon: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                  label: Text(_isProcessing ? 'Scanning...' : 'Capture', style: AppTextStyles.button),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
        const SizedBox(height: AppDimensions.lg),
      ],
    );
  }

  Widget _buildResults() {
    return Column(
      children: [
        GlassContainer(
          borderColor: AppColors.income.withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.income, size: AppDimensions.iconMD),
                  const SizedBox(width: AppDimensions.sm),
                  Text('Receipt Detected', style: AppTextStyles.h3.copyWith(color: AppColors.income)),
                ],
              ),
              const SizedBox(height: AppDimensions.lg),
              if (_parsedResult != null) ...[
                _buildResultRow('Merchant', _parsedResult!.title),
                _buildResultRow('Amount', '₹${_parsedResult!.amount.abs().toStringAsFixed(0)}'),
                _buildResultRow('Category', _parsedResult!.category),
              ] else ...[
                _buildResultRow('Merchant', 'Reliance Fresh'),
                _buildResultRow('Amount', '₹1,245'),
                _buildResultRow('Date', '03 Jun 2026'),
                _buildResultRow('Category', 'Groceries'),
              ]
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: AppDimensions.buttonHeight,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _hasScanned = false);
                    _scanLineController.repeat(reverse: true);
                  },
                  child: const Text('Rescan'),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Container(
                height: AppDimensions.buttonHeight,
                decoration: BoxDecoration(
                  gradient: AppColors.incomeGradient,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  boxShadow: [
                    BoxShadow(color: AppColors.incomeGlow, blurRadius: 12),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (_parsedResult != null) {
                      ref.read(addTransactionProvider)(_parsedResult!);
                    }
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  icon: const Icon(Icons.check_rounded, color: Colors.white),
                  label: Text('Save', style: AppTextStyles.button),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.lg),
      ],
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

