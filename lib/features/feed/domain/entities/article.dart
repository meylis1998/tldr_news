import 'package:equatable/equatable.dart';

class Article extends Equatable {
  const Article({
    required this.id,
    required this.title,
    required this.description,
    required this.link,
    required this.publishedAt,
    required this.category,
    this.isBookmarked = false,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String description;
  final String link;
  final DateTime publishedAt;
  final String category;
  final bool isBookmarked;
  final bool isRead;

  Article copyWith({
    String? id,
    String? title,
    String? description,
    String? link,
    DateTime? publishedAt,
    String? category,
    bool? isBookmarked,
    bool? isRead,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      publishedAt: publishedAt ?? this.publishedAt,
      category: category ?? this.category,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        link,
        publishedAt,
        category,
        isBookmarked,
        isRead,
      ];
}
