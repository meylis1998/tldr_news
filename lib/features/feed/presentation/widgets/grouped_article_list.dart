import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tldr_news/core/constants/api_constants.dart';
import 'package:tldr_news/core/theme/app_colors.dart';
import 'package:tldr_news/core/theme/app_text_styles.dart';
import 'package:tldr_news/core/utils/animations.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';
import 'package:tldr_news/features/feed/presentation/widgets/article_card.dart';
import 'package:tldr_news/shared/widgets/custom_refresh_indicator.dart';

class GroupedArticleList extends StatefulWidget {
  const GroupedArticleList({
    required this.groupedArticles,
    required this.onArticleTap,
    required this.onRefresh,
    this.onBookmarkTap,
    super.key,
  });

  final Map<String, List<Article>> groupedArticles;
  final void Function(Article) onArticleTap;
  final void Function(Article)? onBookmarkTap;
  final Future<void> Function() onRefresh;

  @override
  State<GroupedArticleList> createState() => _GroupedArticleListState();
}

class _GroupedArticleListState extends State<GroupedArticleList> {
  bool _shouldAnimate = true;

  @override
  void didUpdateWidget(GroupedArticleList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupedArticles != widget.groupedArticles) {
      _shouldAnimate = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort categories by the order in ApiConstants
    final sortedCategories = ApiConstants.categorySlugs
        .where((slug) => widget.groupedArticles.containsKey(slug))
        .toList();

    return BrandedRefreshIndicator(
      onRefresh: () async {
        await widget.onRefresh();
        if (mounted) {
          setState(() => _shouldAnimate = true);
        }
      },
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
        itemCount: sortedCategories.length,
        itemBuilder: (context, index) {
          final category = sortedCategories[index];
          final articles = widget.groupedArticles[category] ?? [];
          final newsletter = ApiConstants.getCategory(category);

          Widget section = _CategorySection(
            category: category,
            emoji: newsletter?.emoji ?? '',
            name: newsletter?.name ?? category,
            articles: articles,
            onArticleTap: widget.onArticleTap,
            onBookmarkTap: widget.onBookmarkTap,
            colorIndex: ApiConstants.categorySlugs.indexOf(category),
          );

          // Apply staggered animation for first 5 sections
          if (_shouldAnimate && index < 5) {
            return _StaggeredSection(
              index: index,
              child: section,
            );
          }

          return section;
        },
      ),
    );
  }
}

class _StaggeredSection extends StatefulWidget {
  const _StaggeredSection({
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<_StaggeredSection> createState() => _StaggeredSectionState();
}

class _StaggeredSectionState extends State<_StaggeredSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final delay = widget.index * 80;
    final duration = 350 + delay;

    _controller = AnimationController(
      duration: Duration(milliseconds: duration),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay / duration,
        1.0,
        curve: AppAnimations.entranceCurve,
      ),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay / duration,
        1.0,
        curve: AppAnimations.entranceCurve,
      ),
    ));

    _controller.forward();
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
        return Opacity(
          opacity: _opacityAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.emoji,
    required this.name,
    required this.articles,
    required this.onArticleTap,
    required this.colorIndex,
    this.onBookmarkTap,
  });

  final String category;
  final String emoji;
  final String name;
  final List<Article> articles;
  final void Function(Article) onArticleTap;
  final void Function(Article)? onBookmarkTap;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(colorIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      emoji,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      name,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${articles.length} ${articles.length == 1 ? 'article' : 'articles'}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        ...articles.take(3).map(
              (article) => ArticleCard(
                article: article,
                onTap: () => onArticleTap(article),
                onBookmarkTap:
                    onBookmarkTap != null ? () => onBookmarkTap!(article) : null,
              ),
            ),
        if (articles.length > 3)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              '+${articles.length - 3} more articles',
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
              ),
            ),
          ),
        Divider(
          height: 32.h,
          thickness: 1,
          indent: 16.w,
          endIndent: 16.w,
        ),
      ],
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppColors.primary, // tech
      const Color(0xFF8B5CF6), // ai
      const Color(0xFF3B82F6), // webdev
      const Color(0xFFEF4444), // infosec
      const Color(0xFF06B6D4), // devops
      const Color(0xFF10B981), // founders
      const Color(0xFFF59E0B), // product
      const Color(0xFFEC4899), // design
      const Color(0xFFFF6B6B), // marketing
      const Color(0xFFF7931A), // crypto
      const Color(0xFF00D4AA), // fintech
      const Color(0xFF14B8A6), // data
    ];
    return colors[index % colors.length];
  }
}
