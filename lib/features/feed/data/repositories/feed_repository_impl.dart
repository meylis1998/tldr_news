import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:tldr_news/core/constants/api_constants.dart';
import 'package:tldr_news/core/error/exceptions.dart';
import 'package:tldr_news/core/error/failures.dart';
import 'package:tldr_news/core/network/network_info.dart';
import 'package:tldr_news/features/feed/data/datasources/feed_local_datasource.dart';
import 'package:tldr_news/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';
import 'package:tldr_news/features/feed/domain/repositories/feed_repository.dart';

@LazySingleton(as: FeedRepository)
class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  final FeedRemoteDataSource _remoteDataSource;
  final FeedLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<Article>>> getArticles({
    required String category,
    bool forceRefresh = false,
  }) async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final remoteArticles = await _remoteDataSource.getArticles(category);
        await _localDataSource.saveArticles(category, remoteArticles);
        return Right(remoteArticles.map((m) => m.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      } on NetworkException {
        return _getLocalArticles(category);
      } catch (e) {
        return Left(UnknownFailure(message: e.toString()));
      }
    } else {
      return _getLocalArticles(category);
    }
  }

  Future<Either<Failure, List<Article>>> _getLocalArticles(
    String category,
  ) async {
    try {
      final localArticles = await _localDataSource.getArticles(category);
      if (localArticles.isEmpty) {
        return const Left(
          NetworkFailure(message: 'No internet connection and no cached data'),
        );
      }
      return Right(localArticles.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Article>> getArticleById(String id) async {
    try {
      final article = await _localDataSource.getArticleById(id);
      if (article != null) {
        return Right(article.toEntity());
      }
      return const Left(CacheFailure(message: 'Article not found'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Article>>> searchArticles(String query) async {
    try {
      final allArticles = <Article>[];

      for (final slug in ApiConstants.categorySlugs) {
        final localArticles = await _localDataSource.getArticles(slug);
        allArticles.addAll(localArticles.map((m) => m.toEntity()));
      }

      final uniqueArticles = <String, Article>{};
      for (final article in allArticles) {
        uniqueArticles[article.id] = article;
      }

      final queryLower = query.toLowerCase();
      final results = uniqueArticles.values.where((article) {
        return article.title.toLowerCase().contains(queryLower) ||
            article.description.toLowerCase().contains(queryLower);
      }).toList();

      results.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      return Right(results);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
