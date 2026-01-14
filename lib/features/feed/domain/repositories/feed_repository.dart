import 'package:fpdart/fpdart.dart';
import 'package:tldr_news/core/error/failures.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';

abstract class FeedRepository {
  Future<Either<Failure, List<Article>>> getArticles({
    required String category,
    bool forceRefresh = false,
  });

  Future<Either<Failure, Article>> getArticleById(String id);

  Future<Either<Failure, List<Article>>> searchArticles(String query);
}
