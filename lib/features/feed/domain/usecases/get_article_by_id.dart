import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:tldr_news/core/error/failures.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';
import 'package:tldr_news/features/feed/domain/repositories/feed_repository.dart';

@injectable
class GetArticleById {
  GetArticleById(this._repository);

  final FeedRepository _repository;

  Future<Either<Failure, Article>> call(String id) {
    return _repository.getArticleById(id);
  }
}
