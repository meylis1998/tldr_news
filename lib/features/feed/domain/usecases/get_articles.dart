import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:tldr_news/core/error/failures.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';
import 'package:tldr_news/features/feed/domain/repositories/feed_repository.dart';

@injectable
class GetArticles {
  GetArticles(this._repository);

  final FeedRepository _repository;

  Future<Either<Failure, List<Article>>> call({
    required String category,
    bool forceRefresh = false,
  }) {
    return _repository.getArticles(
      category: category,
      forceRefresh: forceRefresh,
    );
  }
}
