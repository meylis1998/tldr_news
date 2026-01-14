import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:tldr_news/core/error/exceptions.dart';
import 'package:tldr_news/core/error/failures.dart';
import 'package:tldr_news/features/bookmarks/data/datasources/bookmarks_local_datasource.dart';
import 'package:tldr_news/features/bookmarks/domain/repositories/bookmarks_repository.dart';
import 'package:tldr_news/features/feed/data/models/article_model.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';

@LazySingleton(as: BookmarksRepository)
class BookmarksRepositoryImpl implements BookmarksRepository {
  BookmarksRepositoryImpl(this._localDataSource);

  final BookmarksLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<Article>>> getBookmarks() async {
    try {
      final bookmarks = await _localDataSource.getBookmarks();
      return Right(
        bookmarks.map((m) => m.toEntity(isBookmarked: true)).toList(),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addBookmark(Article article) async {
    try {
      await _localDataSource.addBookmark(ArticleModel.fromEntity(article));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeBookmark(String articleId) async {
    try {
      await _localDataSource.removeBookmark(articleId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isBookmarked(String articleId) {
    return _localDataSource.isBookmarked(articleId);
  }
}
