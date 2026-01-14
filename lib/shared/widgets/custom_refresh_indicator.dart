import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tldr_news/core/theme/app_colors.dart';

/// A branded refresh indicator with rotating bolt icon
class TldrRefreshIndicator extends StatefulWidget {
  const TldrRefreshIndicator({
    required this.child,
    required this.onRefresh,
    super.key,
  });

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  State<TldrRefreshIndicator> createState() => _TldrRefreshIndicatorState();
}

class _TldrRefreshIndicatorState extends State<TldrRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    await HapticFeedback.mediumImpact();
    await _rotationController.repeat();

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _rotationController..stop()
        ..reset();
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator.adaptive(
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      displacement: 60,
      child: widget.child,
    );
  }
}

/// A custom refresh indicator that shows a branded loading animation
class BrandedRefreshIndicator extends StatelessWidget {
  const BrandedRefreshIndicator({
    required this.child,
    required this.onRefresh,
    this.color,
    super.key,
  });

  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final indicatorColor = color ?? AppColors.primary;

    return RefreshIndicator(
      onRefresh: () async {
        await HapticFeedback.mediumImpact();
        await onRefresh();
      },
      color: indicatorColor,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      displacement: 50,
      child: child,
    );
  }
}

/// A spinning bolt icon for use in loading states
class SpinningBoltIcon extends StatefulWidget {
  const SpinningBoltIcon({this.size = 24, this.color, super.key});

  final double size;
  final Color? color;

  @override
  State<SpinningBoltIcon> createState() => _SpinningBoltIconState();
}

class _SpinningBoltIconState extends State<SpinningBoltIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: child,
        );
      },
      child: Icon(
        Icons.bolt,
        size: widget.size,
        color: widget.color ?? AppColors.primary,
      ),
    );
  }
}

/// A pull-to-refresh header that shows during pull gesture
class RefreshHeader extends StatelessWidget {
  const RefreshHeader({
    required this.pullProgress,
    required this.isRefreshing,
    super.key,
  });

  final double pullProgress;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 60.h,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isRefreshing)
            SpinningBoltIcon(size: 24.sp)
          else
            Transform.rotate(
              angle: pullProgress * math.pi,
              child: Icon(
                Icons.bolt,
                size: 24.sp,
                color: AppColors.primary.withValues(
                  alpha: pullProgress.clamp(0.3, 1.0),
                ),
              ),
            ),
          SizedBox(width: 12.w),
          Text(
            isRefreshing ? 'Updating...' : 'Pull to refresh',
            style: TextStyle(
              fontSize: 14.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
