import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tldr_news/core/constants/app_constants.dart';
import 'package:tldr_news/core/error/exceptions.dart';

abstract class LocalStorage {
  Future<void> saveArticles(String category, String jsonData);
  Future<String?> getArticles(String category);
  Future<void> saveBookmarks(String jsonData);
  Future<String?> getBookmarks();
  Future<void> saveRecentSearches(List<String> searches);
  Future<List<String>> getRecentSearches();
  Future<void> clear();
}

@LazySingleton(as: LocalStorage)
class LocalStorageImpl implements LocalStorage {
  LocalStorageImpl(this._prefs);

  final SharedPreferences _prefs;

  String _articleKey(String category) => '${AppConstants.articlesBoxKey}_$category';

  @override
  Future<void> saveArticles(String category, String jsonData) async {
    try {
      await _prefs.setString(_articleKey(category), jsonData);
      await _prefs.setInt(
        '${_articleKey(category)}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to save articles: $e');
    }
  }

  @override
  Future<String?> getArticles(String category) async {
    try {
      final timestamp = _prefs.getInt('${_articleKey(category)}_timestamp');
      if (timestamp != null) {
        final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final expirationTime = cachedTime.add(
          Duration(hours: AppConstants.cacheExpirationHours),
        );
        if (DateTime.now().isAfter(expirationTime)) {
          return null;
        }
      }
      return _prefs.getString(_articleKey(category));
    } catch (e) {
      throw CacheException(message: 'Failed to get articles: $e');
    }
  }

  @override
  Future<void> saveBookmarks(String jsonData) async {
    try {
      await _prefs.setString(AppConstants.bookmarksBoxKey, jsonData);
    } catch (e) {
      throw CacheException(message: 'Failed to save bookmarks: $e');
    }
  }

  @override
  Future<String?> getBookmarks() async {
    try {
      return _prefs.getString(AppConstants.bookmarksBoxKey);
    } catch (e) {
      throw CacheException(message: 'Failed to get bookmarks: $e');
    }
  }

  @override
  Future<void> saveRecentSearches(List<String> searches) async {
    try {
      final limitedSearches = searches.take(AppConstants.maxRecentSearches).toList();
      await _prefs.setString(
        AppConstants.recentSearchesKey,
        jsonEncode(limitedSearches),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to save recent searches: $e');
    }
  }

  @override
  Future<List<String>> getRecentSearches() async {
    try {
      final json = _prefs.getString(AppConstants.recentSearchesKey);
      if (json == null) return [];
      final decoded = jsonDecode(json) as List<dynamic>;
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}
