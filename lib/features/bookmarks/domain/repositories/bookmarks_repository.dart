import 'package:fpdart/fpdart.dart';
import 'package:tldr_news/core/error/failures.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';

abstract class BookmarksRepository {
  Future<Either<Failure, List<Article>>> getBookmarks();
  Future<Either<Failure, void>> addBookmark(Article article);
  Future<Either<Failure, void>> removeBookmark(String articleId);
  Future<bool> isBookmarked(String articleId);
}
