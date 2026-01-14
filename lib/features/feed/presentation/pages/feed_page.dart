import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tldr_news/core/constants/api_constants.dart';
import 'package:tldr_news/core/router/app_router.dart';
import 'package:tldr_news/core/theme/app_colors.dart';
import 'package:tldr_news/core/theme/app_text_styles.dart';
import 'package:tldr_news/features/bookmarks/presentation/bloc/bookmarks_bloc.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';
import 'package:tldr_news/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:tldr_news/features/feed/presentation/widgets/article_list.dart';
import 'package:tldr_news/features/feed/presentation/widgets/category_chips.dart';
import 'package:tldr_news/features/feed/presentation/widgets/feed_shimmer.dart';
import 'package:tldr_news/features/feed/presentation/widgets/grouped_article_list.dart';
import 'package:tldr_news/shared/widgets/empty_state_widget.dart';
import 'package:tldr_news/shared/widgets/error_widget.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late PageController _pageController;
  bool _isPageAnimating = false;

  @override
  void initState() {
    super.initState();
    final initialIndex = _getCategoryIndex(
      context.read<FeedBloc>().state.selectedCategory,
    );
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _getCategoryIndex(String category) {
    final index = ApiConstants.newsletters.indexWhere((n) => n.slug == category);
    return index >= 0 ? index : 0;
  }

  void _onPageChanged(int index) {
    if (_isPageAnimating) return;
    final category = ApiConstants.newsletters[index].slug;
    context.read<FeedBloc>().add(FeedCategoryChanged(category));
  }

  void _onCategorySelected(String category) {
    final index = _getCategoryIndex(category);
    _isPageAnimating = true;
    _pageController
        .animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) => _isPageAnimating = false);
    context.read<FeedBloc>().add(FeedCategoryChanged(category));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bolt,
              color: AppColors.primary,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'TLDR.TECH',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<FeedBloc, FeedState>(
            builder: (context, state) {
              if (state.isOffline) {
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Chip(
                    label: Text(
                      'Offline',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: AppColors.warning,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push(AppRoutes.search),
          ),
        ],
      ),
      body: Column(
        children: [
          BlocBuilder<FeedBloc, FeedState>(
            buildWhen: (prev, curr) =>
                prev.selectedCategory != curr.selectedCategory,
            builder: (context, state) {
              return CategoryChips(
                selectedCategory: state.selectedCategory,
                onCategorySelected: _onCategorySelected,
              );
            },
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: BlocBuilder<FeedBloc, FeedState>(
              builder: (context, state) {
                return PageView.builder(
                  controller: _pageController,
                  itemCount: ApiConstants.newsletters.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    return _buildFeedContent(context, state);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedContent(BuildContext context, FeedState state) {
    return switch (state.status) {
      FeedStatus.initial || FeedStatus.loading => const FeedShimmer(),
      FeedStatus.error => AppErrorWidget(
          message: state.errorMessage ?? 'Failed to load articles',
          onRetry: () => context.read<FeedBloc>().add(
                FeedLoadRequested(category: state.selectedCategory),
              ),
        ),
      FeedStatus.loaded => BlocBuilder<BookmarksBloc, BookmarksState>(
          builder: (context, bookmarksState) {
            return state.isAllCategory
                ? _buildGroupedContent(context, state, bookmarksState)
                : _buildSingleCategoryContent(context, state, bookmarksState);
          },
        ),
    };
  }

  Widget _buildGroupedContent(
    BuildContext context,
    FeedState state,
    BookmarksState bookmarksState,
  ) {
    if (state.groupedArticles.isEmpty) {
      return const EmptyStateWidget(
        title: 'No articles',
        message: 'No articles found',
        icon: Icons.article_outlined,
      );
    }

    // Merge bookmark status with grouped articles
    final mergedGroupedArticles = state.groupedArticles.map(
      (category, articles) => MapEntry(
        category,
        articles
            .map((a) => a.copyWith(
                  isBookmarked: bookmarksState.isBookmarked(a.id),
                ))
            .toList(),
      ),
    );

    return GroupedArticleList(
      groupedArticles: mergedGroupedArticles,
      onArticleTap: (article) => _onArticleTap(context, article),
      onBookmarkTap: (article) => _onBookmarkTap(context, article),
      onRefresh: () => context.read<FeedBloc>().refresh(),
    );
  }

  Widget _buildSingleCategoryContent(
    BuildContext context,
    FeedState state,
    BookmarksState bookmarksState,
  ) {
    if (state.articles.isEmpty) {
      return const EmptyStateWidget(
        title: 'No articles',
        message: 'No articles found in this category',
        icon: Icons.article_outlined,
      );
    }

    // Merge bookmark status with articles
    final mergedArticles = state.articles
        .map((a) => a.copyWith(
              isBookmarked: bookmarksState.isBookmarked(a.id),
            ))
        .toList();

    return ArticleList(
      articles: mergedArticles,
      onArticleTap: (article) => _onArticleTap(context, article),
      onBookmarkTap: (article) => _onBookmarkTap(context, article),
      onRefresh: () => context.read<FeedBloc>().refresh(),
    );
  }

  void _onArticleTap(BuildContext context, Article article) {
    context.read<FeedBloc>().add(FeedArticleRead(article.id));
    context.push('/article/${article.id}');
  }

  void _onBookmarkTap(BuildContext context, Article article) {
    final bookmarksBloc = context.read<BookmarksBloc>();
    final isBookmarked = bookmarksBloc.state.isBookmarked(article.id);

    if (isBookmarked) {
      bookmarksBloc.add(BookmarkRemoved(article.id));
    } else {
      bookmarksBloc.add(BookmarkAdded(article));
    }
  }
}
