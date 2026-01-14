part of 'bookmarks_bloc.dart';

enum BookmarksStatus { initial, loading, loaded, error }

class BookmarksState extends Equatable {
  const BookmarksState({
    this.status = BookmarksStatus.initial,
    this.bookmarks = const [],
    this.errorMessage,
  });

  final BookmarksStatus status;
  final List<Article> bookmarks;
  final String? errorMessage;

  bool isBookmarked(String articleId) {
    return bookmarks.any((b) => b.id == articleId);
  }

  BookmarksState copyWith({
    BookmarksStatus? status,
    List<Article>? bookmarks,
    String? errorMessage,
  }) {
    return BookmarksState(
      status: status ?? this.status,
      bookmarks: bookmarks ?? this.bookmarks,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, bookmarks, errorMessage];
}
