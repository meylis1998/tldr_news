part of 'bookmarks_bloc.dart';

abstract class BookmarksEvent extends Equatable {
  const BookmarksEvent();

  @override
  List<Object?> get props => [];
}

class BookmarksLoadRequested extends BookmarksEvent {
  const BookmarksLoadRequested();
}

class BookmarkAdded extends BookmarksEvent {
  const BookmarkAdded(this.article);

  final Article article;

  @override
  List<Object?> get props => [article];
}

class BookmarkRemoved extends BookmarksEvent {
  const BookmarkRemoved(this.articleId);

  final String articleId;

  @override
  List<Object?> get props => [articleId];
}
