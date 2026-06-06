import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';
import 'package:finance_ai/features/insights/providers/insights_provider.dart';
import 'package:finance_ai/features/auth/providers/auth_provider.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});
  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  CameraController? _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _controller = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _processImage(Uint8List imageBytes) async {
    setState(() => _isProcessing = true);
    try {
      final gemini = ref.read(geminiServiceProvider);
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('Please log in first');
      
      final transaction = await gemini.parseReceiptImage(imageBytes, user.uid);
      
      if (transaction == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not read receipt details. Please try again.')));
      } else {
        if (mounted) context.push('/add', extra: transaction);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    HapticFeedback.mediumImpact();
    try {
      final file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();
      await _processImage(bytes);
    } catch (e) {
      debugPrint('Capture error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      await _processImage(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),

          // Overlay Scrim
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),

          // Viewfinder
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  if (_isProcessing)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: AppColors.primary),
                          const SizedBox(height: 16),
                          Text('AI analyzing receipt...', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  // Corner markers
                  _buildCornerMarker(Alignment.topLeft),
                  _buildCornerMarker(Alignment.topRight),
                  _buildCornerMarker(Alignment.bottomLeft),
                  _buildCornerMarker(Alignment.bottomRight),
                ],
              ),
            ),
          ),

          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.flash_off_rounded, color: Colors.white),
                    onPressed: () {}, // Flash toggle
                  ),
                ],
              ),
            ),
          ),

          // Controls
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 32),
                    onPressed: _isProcessing ? null : _pickFromGallery,
                  ),
                  GestureDetector(
                    onTap: _isProcessing ? null : _capturePhoto,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: _isProcessing ? Colors.white30 : AppColors.primary.withValues(alpha: 0.8),
                      ),
                      child: _isProcessing ? const Icon(Icons.hourglass_empty_rounded, color: Colors.white) : null,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerMarker(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft || alignment == Alignment.topRight ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            right: alignment == Alignment.topRight || alignment == Alignment.bottomRight ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
