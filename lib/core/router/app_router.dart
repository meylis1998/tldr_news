import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tldr_news/features/article_detail/presentation/pages/article_detail_page.dart';
import 'package:tldr_news/features/bookmarks/presentation/pages/bookmarks_page.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';
import 'package:tldr_news/features/feed/presentation/pages/feed_page.dart';
import 'package:tldr_news/features/search/presentation/pages/search_page.dart';
import 'package:tldr_news/features/settings/presentation/pages/settings_page.dart';
import 'package:tldr_news/shared/widgets/app_scaffold.dart';

abstract class AppRoutes {
  static const String feed = '/';
  static const String articleDetail = '/article/:id';
  static const String bookmarks = '/bookmarks';
  static const String search = '/search';
  static const String settings = '/settings';
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.feed,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.feed,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: FeedPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.bookmarks,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BookmarksPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsPage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.articleDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final articleId = state.pathParameters['id'] ?? '';
        final article = state.extra as Article?;
        return ArticleDetailPage(articleId: articleId, article: article);
      },
    ),
    GoRoute(
      path: AppRoutes.search,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SearchPage(),
    ),
  ],
);
