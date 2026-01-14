import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tldr_news/core/theme/app_colors.dart';
import 'package:tldr_news/core/theme/app_text_styles.dart';
import 'package:tldr_news/core/utils/animations.dart';
import 'package:tldr_news/core/utils/extensions.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';
import 'package:tldr_news/shared/widgets/animated_bookmark_button.dart';

class ArticleCard extends StatefulWidget {
  const ArticleCard({
    required this.article,
    required this.onTap,
    this.onBookmarkTap,
    this.enableHero = true,
    super.key,
  });

  final Article article;
  final VoidCallback onTap;
  final VoidCallback? onBookmarkTap;
  final bool enableHero;

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.pressScale,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: AppAnimations.pressCurve,
    ));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _pressController.reverse();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor =
        AppColors.categoryColors[widget.article.category] ?? AppColors.primary;

    Widget cardContent = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            if (!isDark)
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          child: InkWell(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetadataRow(colorScheme, categoryColor),
                  SizedBox(height: 12.h),
                  _buildTitle(colorScheme),
                  SizedBox(height: 8.h),
                  _buildDescription(colorScheme),
                  SizedBox(height: 12.h),
                  _buildFooter(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return cardContent;
  }

  Widget _buildMetadataRow(ColorScheme colorScheme, Color categoryColor) {
    return Row(
      children: [
        // Category badge with subtle background
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            widget.article.category.capitalized,
            style: AppTextStyles.labelSmall.copyWith(
              color: categoryColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        // Time indicator with icon
        Icon(
          Icons.schedule_rounded,
          size: 14.sp,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        SizedBox(width: 4.w),
        Text(
          widget.article.publishedAt.timeAgo,
          style: AppTextStyles.labelSmall.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const Spacer(),
        // Animated bookmark button
        if (widget.onBookmarkTap != null)
          AnimatedBookmarkButton(
            isBookmarked: widget.article.isBookmarked,
            onTap: widget.onBookmarkTap!,
            size: 22.sp,
            activeColor: AppColors.primary,
            inactiveColor: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
      ],
    );
  }

  Widget _buildTitle(ColorScheme colorScheme) {
    final titleText = Text(
      widget.article.title,
      style: AppTextStyles.titleMedium.copyWith(
        color: widget.article.isRead
            ? colorScheme.onSurface.withValues(alpha: 0.6)
            : colorScheme.onSurface,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    if (widget.enableHero) {
      return Hero(
        tag: 'article-title-${widget.article.id}',
        flightShuttleBuilder: (_, animation, direction, fromContext, toContext) {
          final toWidget = toContext.widget as Hero;
          return DefaultTextStyle(
            style: AppTextStyles.titleMedium.copyWith(
              color: colorScheme.onSurface,
            ),
            child: Material(
              color: Colors.transparent,
              child: toWidget.child,
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: titleText,
        ),
      );
    }

    return titleText;
  }

  Widget _buildDescription(ColorScheme colorScheme) {
    return Text(
      widget.article.description,
      style: AppTextStyles.bodyMedium.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.65),
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.link_rounded,
                size: 12.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              SizedBox(width: 4.w),
              Text(
                _getDomain(widget.article.link),
                style: AppTextStyles.labelSmall.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }
}
