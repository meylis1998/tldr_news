import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tldr_news/core/utils/animations.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';
import 'package:tldr_news/features/feed/presentation/widgets/article_card.dart';
import 'package:tldr_news/shared/widgets/custom_refresh_indicator.dart';

class ArticleList extends StatefulWidget {
  const ArticleList({
    required this.articles,
    required this.onArticleTap,
    this.onBookmarkTap,
    this.onRefresh,
    super.key,
  });

  final List<Article> articles;
  final void Function(Article article) onArticleTap;
  final void Function(Article article)? onBookmarkTap;
  final Future<void> Function()? onRefresh;

  @override
  State<ArticleList> createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  bool _shouldAnimate = true;

  @override
  void didUpdateWidget(ArticleList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only animate when articles list changes (new data loaded)
    if (oldWidget.articles != widget.articles) {
      _shouldAnimate = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget listView = ListView.builder(
      padding: EdgeInsets.only(top: 8.h, bottom: 100.h),
      itemCount: widget.articles.length,
      itemBuilder: (context, index) {
        final article = widget.articles[index];
        final card = ArticleCard(
          article: article,
          onTap: () => widget.onArticleTap(article),
          onBookmarkTap: widget.onBookmarkTap != null
              ? () => widget.onBookmarkTap!(article)
              : null,
        );

        // Apply staggered animation for first 10 items when list changes
        if (_shouldAnimate && index < 10) {
          return _StaggeredListItem(
            index: index,
            child: card,
          );
        }

        return card;
      },
    );

    if (widget.onRefresh != null) {
      listView = BrandedRefreshIndicator(
        onRefresh: () async {
          await widget.onRefresh!();
          if (mounted) {
            setState(() => _shouldAnimate = true);
          }
        },
        child: listView,
      );
    }

    return listView;
  }
}

class _StaggeredListItem extends StatefulWidget {
  const _StaggeredListItem({
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<_StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<_StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final delay = widget.index * 50;
    final duration = 300 + delay;

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
      begin: const Offset(0, 0.1),
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
