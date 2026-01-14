import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tldr_news/core/theme/app_colors.dart';
import 'package:tldr_news/core/theme/app_text_styles.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64.sp,
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  const NetworkErrorWidget({
    this.onRetry,
    super.key,
  });

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      message: 'No internet connection.\nPlease check your network settings.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}
