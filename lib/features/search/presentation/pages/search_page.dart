import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tldr_news/core/di/injection.dart';
import 'package:tldr_news/core/theme/app_text_styles.dart';
import 'package:tldr_news/features/bookmarks/presentation/bloc/bookmarks_bloc.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';
import 'package:tldr_news/features/feed/presentation/widgets/article_card.dart';
import 'package:tldr_news/features/search/presentation/bloc/search_bloc.dart';
import 'package:tldr_news/features/search/presentation/widgets/search_bar_widget.dart';
import 'package:tldr_news/shared/widgets/empty_state_widget.dart';
import 'package:tldr_news/shared/widgets/loading_indicator.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SearchBloc>()..add(const RecentSearchesLoaded()),
      child: const _SearchPageContent(),
    );
  }
}

class _SearchPageContent extends StatefulWidget {
  const _SearchPageContent();

  @override
  State<_SearchPageContent> createState() => _SearchPageContentState();
}

class _SearchPageContentState extends State<_SearchPageContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: BlocBuilder<SearchBloc, SearchState>(
          buildWhen: (prev, curr) => prev.query != curr.query,
          builder: (context, state) {
            return SearchBarWidget(
              controller: _searchController,
              onChanged: (query) {
                context.read<SearchBloc>().add(SearchQueryChanged(query));
              },
              onClear: () {
                _searchController.clear();
                context.read<SearchBloc>().add(const SearchCleared());
              },
            );
          },
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state.query.isEmpty) {
            return _buildRecentSearches(context, state);
          }

          return switch (state.status) {
            SearchStatus.initial => const SizedBox.shrink(),
            SearchStatus.loading => const LoadingIndicator(),
            SearchStatus.error => EmptyStateWidget(
                title: 'Search failed',
                message: state.errorMessage,
                icon: Icons.error_outline,
              ),
            SearchStatus.loaded => state.results.isEmpty
                ? EmptyStateWidget(
                    title: 'No results found',
                    message: 'Try searching with different keywords',
                    icon: Icons.search_off,
                  )
                : _buildSearchResults(context, state.results),
          };
        },
      ),
    );
  }

  Widget _buildRecentSearches(BuildContext context, SearchState state) {
    if (state.recentSearches.isEmpty) {
      return const EmptyStateWidget(
        title: 'Search articles',
        message: 'Find articles by title or description',
        icon: Icons.search,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: Text(
            'Recent Searches',
            style: AppTextStyles.titleSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.recentSearches.length,
            itemBuilder: (context, index) {
              final search = state.recentSearches[index];
              return ListTile(
                leading: Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                title: Text(search),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    context.read<SearchBloc>().add(RecentSearchRemoved(search));
                  },
                ),
                onTap: () {
                  _searchController.text = search;
                  context.read<SearchBloc>().add(SearchQueryChanged(search));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context, List<Article> results) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final article = results[index];
        return ArticleCard(
          article: article,
          onTap: () => _onArticleTap(context, article),
          onBookmarkTap: () => _onBookmarkTap(context, article),
        );
      },
    );
  }

  void _onArticleTap(BuildContext context, Article article) {
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
