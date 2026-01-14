import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tldr_news/core/utils/date_formatter.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';
import 'package:xml/xml.dart';

part 'article_model.g.dart';

@JsonSerializable()
class ArticleModel {
  const ArticleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.link,
    required this.publishedAt,
    required this.category,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) =>
      _$ArticleModelFromJson(json);

  factory ArticleModel.fromXmlElement(XmlElement element, String category) {
    final title = element.getElement('title')?.innerText ?? '';
    final description = _cleanHtml(
      element.getElement('description')?.innerText ?? '',
    );
    final link = element.getElement('guid')?.innerText ?? '';
    final pubDate = element.getElement('pubDate')?.innerText;
    final publishedAt = DateFormatter.parseRfc2822(pubDate) ?? DateTime.now();

    return ArticleModel(
      id: _generateId(link),
      title: title.trim(),
      description: description.trim(),
      link: link.trim(),
      publishedAt: publishedAt,
      category: category,
    );
  }

  final String id;
  final String title;
  final String description;
  final String link;
  final DateTime publishedAt;
  final String category;

  Map<String, dynamic> toJson() => _$ArticleModelToJson(this);

  Article toEntity({bool isBookmarked = false, bool isRead = false}) {
    return Article(
      id: id,
      title: title,
      description: description,
      link: link,
      publishedAt: publishedAt,
      category: category,
      isBookmarked: isBookmarked,
      isRead: isRead,
    );
  }

  static ArticleModel fromEntity(Article article) {
    return ArticleModel(
      id: article.id,
      title: article.title,
      description: article.description,
      link: article.link,
      publishedAt: article.publishedAt,
      category: article.category,
    );
  }

  static String _generateId(String link) {
    final bytes = utf8.encode(link);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  static String _cleanHtml(String html) {
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

  static List<ArticleModel> parseRssFeed(String xmlString, String category) {
    try {
      final document = XmlDocument.parse(xmlString);
      final items = document.findAllElements('item');
      return items
          .map((item) => ArticleModel.fromXmlElement(item, category))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
