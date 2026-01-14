part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class FeedLoadRequested extends FeedEvent {
  const FeedLoadRequested({this.category = 'tech'});

  final String category;

  @override
  List<Object?> get props => [category];
}

class FeedRefreshRequested extends FeedEvent {
  const FeedRefreshRequested();
}

class FeedCategoryChanged extends FeedEvent {
  const FeedCategoryChanged(this.category);

  final String category;

  @override
  List<Object?> get props => [category];
}

class FeedArticleRead extends FeedEvent {
  const FeedArticleRead(this.articleId);

  final String articleId;

  @override
  List<Object?> get props => [articleId];
}
