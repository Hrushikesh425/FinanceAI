import 'package:flutter/material.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';
import 'package:finance_ai/core/constants/app_text_styles.dart';

class FileUploadWidget extends StatefulWidget {
  final Function(String) onFileSelected;

  const FileUploadWidget({super.key, required this.onFileSelected});

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  bool _isUploading = false;
  double _progress = 0.0;
  String? _fileName;

  void _simulateUpload() {
    setState(() {
      _isUploading = true;
      _progress = 0.0;
      _fileName = 'document.pdf';
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _progress = 0.3);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _progress = 0.7);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _progress = 1.0;
          _isUploading = false;
        });
        widget.onFileSelected(_fileName!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_fileName != null && !_isUploading) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.cardBgLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.description_rounded, color: AppColors.primary),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Text(
                _fileName!,
                style: AppTextStyles.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.error),
              onPressed: () => setState(() => _fileName = null),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _isUploading ? null : _simulateUpload,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
          color: AppColors.cardBgLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              _isUploading ? Icons.cloud_upload_rounded : Icons.upload_file_rounded,
              size: 48,
              color: _isUploading ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(height: AppDimensions.md),
            if (_isUploading) ...[
              Text('Uploading...', style: AppTextStyles.body),
              const SizedBox(height: AppDimensions.sm),
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ] else ...[
              Text('Tap to upload document', style: AppTextStyles.h3),
              const SizedBox(height: AppDimensions.xs),
              Text('PDF, JPG, PNG (Max 10MB)', style: AppTextStyles.caption),
            ],
          ],
        ),
      ),
    );
  }
}
