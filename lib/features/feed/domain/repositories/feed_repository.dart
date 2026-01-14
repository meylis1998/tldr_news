import 'package:fpdart/fpdart.dart';
import 'package:tldr_news/core/error/failures.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';

abstract class FeedRepository {
  Future<Either<Failure, List<Article>>> getArticles({
    required String category,
    bool forceRefresh = false,
  });

  /// Fetches articles from all newsletters in parallel and groups by category
  Future<Either<Failure, Map<String, List<Article>>>> getAllArticlesGrouped({
    bool forceRefresh = false,
  });

  Future<Either<Failure, Article>> getArticleById(String id);

  Future<Either<Failure, List<Article>>> searchArticles(String query);
}
