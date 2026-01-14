import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:tldr_news/core/error/exceptions.dart';
import 'package:tldr_news/core/storage/local_storage.dart';
import 'package:tldr_news/features/feed/data/models/article_model.dart';

abstract class BookmarksLocalDataSource {
  Future<List<ArticleModel>> getBookmarks();
  Future<void> addBookmark(ArticleModel article);
  Future<void> removeBookmark(String articleId);
  Future<bool> isBookmarked(String articleId);
}

@LazySingleton(as: BookmarksLocalDataSource)
class BookmarksLocalDataSourceImpl implements BookmarksLocalDataSource {
  BookmarksLocalDataSourceImpl(this._localStorage);

  final LocalStorage _localStorage;

  @override
  Future<List<ArticleModel>> getBookmarks() async {
    try {
      final json = await _localStorage.getBookmarks();
      if (json == null) return [];

      final decoded = jsonDecode(json) as List<dynamic>;
      return decoded
          .map((item) => ArticleModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get bookmarks: $e');
    }
  }

  @override
  Future<void> addBookmark(ArticleModel article) async {
    try {
      final bookmarks = await getBookmarks();
      if (!bookmarks.any((b) => b.id == article.id)) {
        bookmarks.insert(0, article);
        await _saveBookmarks(bookmarks);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to add bookmark: $e');
    }
  }

  @override
  Future<void> removeBookmark(String articleId) async {
    try {
      final bookmarks = await getBookmarks();
      bookmarks.removeWhere((b) => b.id == articleId);
      await _saveBookmarks(bookmarks);
    } catch (e) {
      throw CacheException(message: 'Failed to remove bookmark: $e');
    }
  }

  @override
  Future<bool> isBookmarked(String articleId) async {
    try {
      final bookmarks = await getBookmarks();
      return bookmarks.any((b) => b.id == articleId);
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveBookmarks(List<ArticleModel> bookmarks) async {
    final json = jsonEncode(bookmarks.map((b) => b.toJson()).toList());
    await _localStorage.saveBookmarks(json);
  }
}
