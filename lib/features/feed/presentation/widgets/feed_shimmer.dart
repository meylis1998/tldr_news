import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tldr_news/core/theme/app_colors.dart';

class FeedShimmer extends StatelessWidget {
  const FeedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Optimized colors for better dark mode contrast
    final baseColor = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.8)
        : Colors.grey[300]!;
    final highlightColor = isDark
        ? AppColors.darkDivider.withValues(alpha: 0.6)
        : Colors.grey[100]!;
    final placeholderColor = isDark
        ? AppColors.darkDivider
        : Colors.grey[200]!;

    return ListView.builder(
      padding: EdgeInsets.only(top: 8.h),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: _ShimmerCard(placeholderColor: placeholderColor),
        );
      },
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.placeholderColor});

  final Color placeholderColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ShimmerBox(
                  width: 60.w,
                  height: 20.h,
                  borderRadius: 6.r,
                  color: placeholderColor,
                ),
                SizedBox(width: 8.w),
                _ShimmerBox(
                  width: 50.w,
                  height: 14.h,
                  borderRadius: 4.r,
                  color: placeholderColor,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _ShimmerBox(
              width: double.infinity,
              height: 18.h,
              borderRadius: 4.r,
              color: placeholderColor,
            ),
            SizedBox(height: 8.h),
            _ShimmerBox(
              width: 200.w,
              height: 18.h,
              borderRadius: 4.r,
              color: placeholderColor,
            ),
            SizedBox(height: 12.h),
            _ShimmerBox(
              width: double.infinity,
              height: 14.h,
              borderRadius: 4.r,
              color: placeholderColor,
            ),
            SizedBox(height: 6.h),
            _ShimmerBox(
              width: double.infinity,
              height: 14.h,
              borderRadius: 4.r,
              color: placeholderColor,
            ),
            SizedBox(height: 6.h),
            _ShimmerBox(
              width: 250.w,
              height: 14.h,
              borderRadius: 4.r,
              color: placeholderColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.color,
  });

  final double width;
  final double height;
  final double borderRadius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
