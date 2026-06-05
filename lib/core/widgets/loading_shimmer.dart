import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:finance_ai/core/constants/app_colors.dart';
import 'package:finance_ai/core/constants/app_dimensions.dart';

class LoadingShimmer extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final int count;
  final EdgeInsetsGeometry? margin;

  const LoadingShimmer({
    super.key,
    this.width,
    this.height = 80,
    this.borderRadius = AppDimensions.radiusLG,
    this.count = 1,
    this.margin,
  });

  const LoadingShimmer.card({
    super.key,
    this.height = 80,
    this.borderRadius = AppDimensions.radiusLG,
    this.count = 3,
    this.margin,
  }) : width = double.infinity;

  const LoadingShimmer.text({
    super.key,
    this.width = 100,
    this.height = 14,
    this.borderRadius = AppDimensions.radiusSM,
    this.margin,
  }) : count = 1;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardBg,
      highlightColor: AppColors.cardBgLight,
      child: Column(
        children: List.generate(count, (index) {
          return Container(
            width: width,
            height: height,
            margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          );
        }),
      ),
    );
  }
}
