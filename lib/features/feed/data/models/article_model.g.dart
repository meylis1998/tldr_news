// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArticleModel _$ArticleModelFromJson(Map<String, dynamic> json) => ArticleModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  link: json['link'] as String,
  publishedAt: DateTime.parse(json['publishedAt'] as String),
  category: json['category'] as String,
);

Map<String, dynamic> _$ArticleModelToJson(ArticleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'link': instance.link,
      'publishedAt': instance.publishedAt.toIso8601String(),
      'category': instance.category,
    };
