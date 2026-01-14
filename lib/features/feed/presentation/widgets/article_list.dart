import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';
import 'package:tldr_news/features/feed/presentation/widgets/article_card.dart';

class ArticleList extends StatelessWidget {
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
  Widget build(BuildContext context) {
    Widget listView = ListView.builder(
      padding: EdgeInsets.only(top: 8.h, bottom: 100.h),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return ArticleCard(
          article: article,
          onTap: () => onArticleTap(article),
          onBookmarkTap: onBookmarkTap != null
              ? () => onBookmarkTap!(article)
              : null,
        );
      },
    );

    if (onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: onRefresh!,
        child: listView,
      );
    }

    return listView;
  }
}
