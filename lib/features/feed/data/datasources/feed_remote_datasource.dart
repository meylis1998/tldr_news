import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tldr_news/core/constants/api_constants.dart';
import 'package:tldr_news/core/error/exceptions.dart';
import 'package:tldr_news/features/feed/data/datasources/newsletter_scraper.dart';
import 'package:tldr_news/features/feed/data/models/article_model.dart';

abstract class FeedRemoteDataSource {
  Future<List<ArticleModel>> getArticles(String newsletter);
}

@LazySingleton(as: FeedRemoteDataSource)
class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  FeedRemoteDataSourceImpl(this._dio, this._scraper);

  final Dio _dio;
  final NewsletterScraper _scraper;

  /// Number of recent newsletter issues to scrape for articles.
  static const int _issuesToFetch = 3;

  @override
  Future<List<ArticleModel>> getArticles(String newsletter) async {
    try {
      // First get the RSS feed to know available dates
      final url = ApiConstants.getRssFeedUrl(newsletter);
      final response = await _dio.get<String>(url);

      if (response.statusCode != 200 || response.data == null) {
        throw ServerException(
          message: 'Failed to fetch RSS feed',
          statusCode: response.statusCode,
        );
      }

      // Parse RSS to get dates
      final dates = _extractDatesFromRss(response.data!);

      if (dates.isEmpty) {
        throw const ServerException(message: 'No newsletter issues found');
      }

      // Scrape the most recent newsletters to get full articles with summaries
      final allArticles = <ArticleModel>[];
      final datesToFetch = dates.take(_issuesToFetch).toList();

      for (final date in datesToFetch) {
        try {
          final articles = await _scraper.scrapeNewsletter(
            newsletter: newsletter,
            date: date,
          );
          allArticles.addAll(articles);
        } catch (e) {
          // Continue with other dates if one fails
          continue;
        }
      }

      if (allArticles.isEmpty) {
        throw const ServerException(
          message: 'Failed to fetch any articles from newsletter',
        );
      }

      // Sort by date descending
      allArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      return allArticles;
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

  /// Extracts dates from RSS feed items.
  List<String> _extractDatesFromRss(String xmlString) {
    final dates = <String>[];
    // Match dates in format YYYY-MM-DD from link URLs
    final dateRegex = RegExp(r'(\d{4}-\d{2}-\d{2})');
    final matches = dateRegex.allMatches(xmlString);

    final seenDates = <String>{};
    for (final match in matches) {
      final date = match.group(1);
      if (date != null && !seenDates.contains(date)) {
        seenDates.add(date);
        dates.add(date);
      }
    }

    // Sort descending (most recent first)
    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }
}
