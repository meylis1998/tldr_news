import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tldr_news/features/bookmarks/domain/repositories/bookmarks_repository.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';

part 'bookmarks_event.dart';
part 'bookmarks_state.dart';

@injectable
class BookmarksBloc extends Bloc<BookmarksEvent, BookmarksState> {
  BookmarksBloc(this._repository) : super(const BookmarksState()) {
    on<BookmarksLoadRequested>(_onLoadRequested);
    on<BookmarkAdded>(_onBookmarkAdded);
    on<BookmarkRemoved>(_onBookmarkRemoved);
  }

  final BookmarksRepository _repository;

  Future<void> _onLoadRequested(
    BookmarksLoadRequested event,
    Emitter<BookmarksState> emit,
  ) async {
    emit(state.copyWith(status: BookmarksStatus.loading));

    final result = await _repository.getBookmarks();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BookmarksStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (bookmarks) => emit(
        state.copyWith(
          status: BookmarksStatus.loaded,
          bookmarks: bookmarks,
        ),
      ),
    );
  }

  Future<void> _onBookmarkAdded(
    BookmarkAdded event,
    Emitter<BookmarksState> emit,
  ) async {
    final result = await _repository.addBookmark(event.article);

    result.fold(
      (failure) => null,
      (_) {
        final updatedBookmarks = [
          event.article.copyWith(isBookmarked: true),
          ...state.bookmarks,
        ];
        emit(state.copyWith(bookmarks: updatedBookmarks));
      },
    );
  }

  Future<void> _onBookmarkRemoved(
    BookmarkRemoved event,
    Emitter<BookmarksState> emit,
  ) async {
    final result = await _repository.removeBookmark(event.articleId);

    result.fold(
      (failure) => null,
      (_) {
        final updatedBookmarks = state.bookmarks
            .where((b) => b.id != event.articleId)
            .toList();
        emit(state.copyWith(bookmarks: updatedBookmarks));
      },
    );
  }
}
