import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tldr_news/features/bookmarks/presentation/bloc/bookmarks_bloc.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';
import 'package:tldr_news/features/feed/presentation/widgets/article_card.dart';
import 'package:tldr_news/shared/widgets/empty_state_widget.dart';
import 'package:tldr_news/shared/widgets/error_widget.dart';
import 'package:tldr_news/shared/widgets/loading_indicator.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: BlocBuilder<BookmarksBloc, BookmarksState>(
        builder: (context, state) {
          return switch (state.status) {
            BookmarksStatus.initial || BookmarksStatus.loading =>
              const LoadingIndicator(),
            BookmarksStatus.error => AppErrorWidget(
                message: state.errorMessage ?? 'Failed to load bookmarks',
                onRetry: () => context
                    .read<BookmarksBloc>()
                    .add(const BookmarksLoadRequested()),
              ),
            BookmarksStatus.loaded => state.bookmarks.isEmpty
                ? const EmptyStateWidget(
                    title: 'No bookmarks yet',
                    message: 'Articles you bookmark will appear here',
                    icon: Icons.bookmark_outline,
                  )
                : _BookmarksList(
                    bookmarks: state.bookmarks,
                    onArticleTap: (article) => _onArticleTap(context, article),
                    onRemove: (article) => _onRemoveBookmark(context, article),
                  ),
          };
        },
      ),
    );
  }

  void _onArticleTap(BuildContext context, Article article) {
    context.push('/article/${article.id}', extra: article);
  }

  void _onRemoveBookmark(BuildContext context, Article article) {
    context.read<BookmarksBloc>().add(BookmarkRemoved(article.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Bookmark removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            context.read<BookmarksBloc>().add(BookmarkAdded(article));
          },
        ),
      ),
    );
  }
}

class _BookmarksList extends StatelessWidget {
  const _BookmarksList({
    required this.bookmarks,
    required this.onArticleTap,
    required this.onRemove,
  });

  final List<Article> bookmarks;
  final void Function(Article) onArticleTap;
  final void Function(Article) onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 8.h, bottom: 100.h),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final article = bookmarks[index];
        return Dismissible(
          key: Key(article.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 24.w),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => onRemove(article),
          child: ArticleCard(
            article: article,
            onTap: () => onArticleTap(article),
          ),
        );
      },
    );
  }
}
