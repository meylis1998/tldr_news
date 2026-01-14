import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:injectable/injectable.dart';
import 'package:tldr_news/core/constants/api_constants.dart';
import 'package:tldr_news/core/error/exceptions.dart';
import 'package:tldr_news/features/feed/data/models/article_model.dart';

/// Scrapes TLDR newsletter HTML pages to extract articles with summaries.
abstract class NewsletterScraper {
  /// Fetches and parses a newsletter page, returning individual articles.
  Future<List<ArticleModel>> scrapeNewsletter({
    required String newsletter,
    required String date,
  });

  /// Gets articles from the latest newsletter issue.
  Future<List<ArticleModel>> scrapeLatestNewsletter(String newsletter);
}

@LazySingleton(as: NewsletterScraper)
class NewsletterScraperImpl implements NewsletterScraper {
  NewsletterScraperImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<ArticleModel>> scrapeNewsletter({
    required String newsletter,
    required String date,
  }) async {
    try {
      final url = ApiConstants.getIssueUrl(newsletter, date);
      final response = await _dio.get<String>(url);

      if (response.statusCode == 200 && response.data != null) {
        return _parseNewsletterHtml(response.data!, newsletter, date);
      } else {
        throw ServerException(
          message: 'Failed to fetch newsletter page',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkException();
      }
      throw ServerException(
        message: e.message ?? 'Failed to fetch newsletter',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<ArticleModel>> scrapeLatestNewsletter(String newsletter) async {
    try {
      // First get the latest URL which redirects to the dated URL
      final latestUrl = ApiConstants.getLatestUrl(newsletter);
      final response = await _dio.get<String>(
        latestUrl,
        options: Options(followRedirects: true),
      );

      if (response.statusCode == 200 && response.data != null) {
        // Extract date from final URL
        final finalUrl = response.realUri.toString();
        final dateMatch = RegExp(r'(\d{4}-\d{2}-\d{2})').firstMatch(finalUrl);
        final date = dateMatch?.group(1) ?? DateTime.now().toIso8601String().split('T')[0];

        return _parseNewsletterHtml(response.data!, newsletter, date);
      } else {
        throw ServerException(
          message: 'Failed to fetch latest newsletter',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkException();
      }
      throw ServerException(
        message: e.message ?? 'Failed to fetch newsletter',
        statusCode: e.response?.statusCode,
      );
    }
  }

  List<ArticleModel> _parseNewsletterHtml(
    String htmlContent,
    String newsletter,
    String date,
  ) {
    final document = html_parser.parse(htmlContent);
    final articles = <ArticleModel>[];

    // Find all article elements
    final articleElements = document.querySelectorAll('article');

    for (final articleElement in articleElements) {
      try {
        // Extract URL - check article href attribute first, then inner a tag
        var link = articleElement.attributes['href'] ?? '';
        if (link.isEmpty) {
          final linkElement = articleElement.querySelector('a[href]');
          link = linkElement?.attributes['href'] ?? '';
        }

        // Skip if link is empty or internal TLDR link
        if (link.isEmpty || link.contains('tldr.tech')) continue;

        // Extract title from h3 inside the link
        final titleElement = articleElement.querySelector('h3');
        var title = titleElement?.text.trim() ?? '';

        // Skip if no title
        if (title.isEmpty) continue;

        // Skip sponsored content
        if (title.toLowerCase().contains('[sponsor]') ||
            title.toLowerCase().contains('(sponsor)')) {
          continue;
        }

        // Clean title - remove read time suffix like "(4 minute read)"
        title = _cleanTitle(title);

        // Extract summary from div (usually has class newsletter-html)
        final summaryElement = articleElement.querySelector('div');
        var summary = '';

        if (summaryElement != null) {
          // Get text content, cleaning up HTML
          summary = _cleanHtml(summaryElement.innerHtml);
        }

        // If summary is still empty, try getting text from all divs
        if (summary.isEmpty) {
          final allDivs = articleElement.querySelectorAll('div');
          for (final div in allDivs) {
            final text = _cleanHtml(div.innerHtml);
            if (text.length > summary.length) {
              summary = text;
            }
          }
        }

        // Skip if no summary
        if (summary.isEmpty) continue;

        // Generate unique ID from link
        final id = _generateId(link);

        // Parse date
        final publishedAt = DateTime.tryParse(date) ?? DateTime.now();

        articles.add(ArticleModel(
          id: id,
          title: title,
          description: summary,
          link: link,
          publishedAt: publishedAt,
          category: newsletter,
        ));
      } catch (e) {
        // Skip malformed articles
        continue;
      }
    }

    return articles;
  }

  /// Cleans the title by removing read time suffix.
  String _cleanTitle(String title) {
    // Remove patterns like "(4 minute read)" or "(2 min read)"
    return title
        .replaceAll(RegExp(r'\s*\(\d+\s*min(ute)?\s*read\)', caseSensitive: false), '')
        .trim();
  }

  String _generateId(String link) {
    final bytes = utf8.encode(link);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
