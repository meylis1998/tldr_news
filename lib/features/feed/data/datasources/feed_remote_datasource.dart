import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tldr_news/core/constants/api_constants.dart';
import 'package:tldr_news/core/error/exceptions.dart';
import 'package:tldr_news/features/feed/data/models/article_model.dart';

abstract class FeedRemoteDataSource {
  Future<List<ArticleModel>> getArticles(String newsletter);
}

@LazySingleton(as: FeedRemoteDataSource)
class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  FeedRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<ArticleModel>> getArticles(String newsletter) async {
    try {
      final url = ApiConstants.getRssFeedUrl(newsletter);
      final response = await _dio.get<String>(url);

      if (response.statusCode == 200 && response.data != null) {
        return ArticleModel.parseRssFeed(response.data!, newsletter);
      } else {
        throw ServerException(
          message: 'Failed to fetch articles',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkException();
      }
      throw ServerException(
        message: e.message ?? 'Failed to fetch articles',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
