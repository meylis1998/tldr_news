part of 'bookmarks_bloc.dart';

enum BookmarksStatus { initial, loading, loaded, error }

class BookmarksState extends Equatable {
  BookmarksState({
    this.status = BookmarksStatus.initial,
    this.bookmarks = const [],
    this.errorMessage,
  }) : _bookmarkedIds = bookmarks.map((b) => b.id).toSet();

  final BookmarksStatus status;
  final List<Article> bookmarks;
  final String? errorMessage;
  final Set<String> _bookmarkedIds;

  /// O(1) lookup for checking if an article is bookmarked
  bool isBookmarked(String articleId) {
    return _bookmarkedIds.contains(articleId);
  }

  /// Get the set of bookmarked article IDs (for efficient bulk operations)
  Set<String> get bookmarkedIds => _bookmarkedIds;

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
