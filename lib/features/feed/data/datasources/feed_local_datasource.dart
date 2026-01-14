import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:tldr_news/core/constants/api_constants.dart';
import 'package:tldr_news/core/error/exceptions.dart';
import 'package:tldr_news/core/storage/local_storage.dart';
import 'package:tldr_news/features/feed/data/models/article_model.dart';

abstract class FeedLocalDataSource {
  Future<List<ArticleModel>> getArticles(String category);
  Future<void> saveArticles(String category, List<ArticleModel> articles);
  Future<ArticleModel?> getArticleById(String id);
}

@LazySingleton(as: FeedLocalDataSource)
class FeedLocalDataSourceImpl implements FeedLocalDataSource {
  FeedLocalDataSourceImpl(this._localStorage);

  final LocalStorage _localStorage;

  @override
  Future<List<ArticleModel>> getArticles(String category) async {
    try {
      final json = await _localStorage.getArticles(category);
      if (json == null) return [];

      final decoded = jsonDecode(json) as List<dynamic>;
      return decoded
          .map((item) => ArticleModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get cached articles: $e');
    }
  }

  @override
  Future<void> saveArticles(
    String category,
    List<ArticleModel> articles,
  ) async {
    try {
      final json = jsonEncode(articles.map((a) => a.toJson()).toList());
      await _localStorage.saveArticles(category, json);
    } catch (e) {
      throw CacheException(message: 'Failed to save articles: $e');
    }
  }

  @override
  Future<ArticleModel?> getArticleById(String id) async {
    try {
      for (final slug in ApiConstants.categorySlugs) {
        final articles = await getArticles(slug);
        final found = articles.where((a) => a.id == id).firstOrNull;
        if (found != null) return found;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
