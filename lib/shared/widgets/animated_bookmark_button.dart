import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tldr_news/core/utils/animations.dart';

/// An animated bookmark button with scale and color transitions
class AnimatedBookmarkButton extends StatefulWidget {
  const AnimatedBookmarkButton({
    required this.isBookmarked,
    required this.onTap,
    this.size = 22.0,
    this.activeColor,
    this.inactiveColor,
    super.key,
  });

  final bool isBookmarked;
  final VoidCallback onTap;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  State<AnimatedBookmarkButton> createState() => _AnimatedBookmarkButtonState();
}

class _AnimatedBookmarkButtonState extends State<AnimatedBookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _wasBookmarked = false;

  @override
  void initState() {
    super.initState();
    _wasBookmarked = widget.isBookmarked;
    _controller = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedBookmarkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation when bookmark state changes to true
    if (widget.isBookmarked && !_wasBookmarked) {
      _controller.forward(from: 0);
    }
    _wasBookmarked = widget.isBookmarked;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = widget.activeColor ?? colorScheme.primary;
    final inactiveColor =
        widget.inactiveColor ?? colorScheme.onSurface.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: AnimatedSwitcher(
            duration: AppAnimations.fast,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Icon(
              widget.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              key: ValueKey(widget.isBookmarked),
              color: widget.isBookmarked ? activeColor : inactiveColor,
              size: widget.size,
            ),
          ),
        ),
      ),
    );
  }
}
