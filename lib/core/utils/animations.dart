import 'package:flutter/material.dart';

/// Animation constants for consistent animations throughout the app
abstract class AppAnimations {
  /// Fast animation duration (150ms) - for micro-interactions
  static const Duration fast = Duration(milliseconds: 150);

  /// Medium animation duration (250ms) - for standard transitions
  static const Duration medium = Duration(milliseconds: 250);

  /// Slow animation duration (400ms) - for emphasis transitions
  static const Duration slow = Duration(milliseconds: 400);

  /// Stagger delay between list items
  static const Duration staggerDelay = Duration(milliseconds: 50);

  /// Default curve for most animations
  static const Curve defaultCurve = Curves.easeOutCubic;

  /// Curve for press feedback animations
  static const Curve pressCurve = Curves.easeInOut;

  /// Curve for entrance animations
  static const Curve entranceCurve = Curves.easeOutCubic;

  /// Curve for exit animations
  static const Curve exitCurve = Curves.easeInCubic;

  /// Scale factor for press feedback
  static const double pressScale = 0.98;
}

/// A widget that animates its child with a staggered fade and slide effect
class StaggeredFadeSlide extends StatelessWidget {
  const StaggeredFadeSlide({
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.slideOffset = 20.0,
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  final int index;
  final Widget child;
  final Duration duration;
  final Duration staggerDelay;
  final double slideOffset;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final totalDelay = staggerDelay.inMilliseconds * index;
    final totalDuration = duration.inMilliseconds + totalDelay;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: totalDuration),
      curve: curve,
      builder: (context, value, child) {
        // Calculate the actual progress accounting for the stagger delay
        final delayProgress = totalDelay / totalDuration;
        final adjustedValue = value <= delayProgress
            ? 0.0
            : ((value - delayProgress) / (1 - delayProgress)).clamp(0.0, 1.0);

        return Opacity(
          opacity: adjustedValue,
          child: Transform.translate(
            offset: Offset(0, slideOffset * (1 - adjustedValue)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// A widget that provides scale animation on press
class PressableScale extends StatefulWidget {
  const PressableScale({
    required this.child,
    required this.onTap,
    this.scale = AppAnimations.pressScale,
    this.duration = AppAnimations.fast,
    super.key,
  });

  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final Duration duration;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.pressCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
