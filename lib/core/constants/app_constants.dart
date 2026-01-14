abstract class AppConstants {
  static const String appName = 'TLDR News';
  static const String appVersion = '1.0.0';

  static const String articlesBoxKey = 'articles_cache';
  static const String bookmarksBoxKey = 'bookmarks';
  static const String settingsBoxKey = 'settings';
  static const String recentSearchesKey = 'recent_searches';

  static const int maxRecentSearches = 10;
  static const int cacheExpirationHours = 4;

  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration refreshInterval = Duration(hours: 4);
}
