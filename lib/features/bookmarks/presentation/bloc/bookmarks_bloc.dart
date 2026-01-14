import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tldr_news/features/bookmarks/domain/repositories/bookmarks_repository.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';

part 'bookmarks_event.dart';
part 'bookmarks_state.dart';

@injectable
class BookmarksBloc extends Bloc<BookmarksEvent, BookmarksState> {
  BookmarksBloc(this._repository) : super(BookmarksState()) {
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
    // Optimistically update the UI
    final updatedBookmarks = [
      event.article.copyWith(isBookmarked: true),
      ...state.bookmarks.where((b) => b.id != event.article.id),
    ];
    emit(state.copyWith(bookmarks: updatedBookmarks));

    // Persist to storage
    final result = await _repository.addBookmark(event.article);

    result.fold(
      (failure) {
        // Rollback on failure
        final rolledBackBookmarks =
            state.bookmarks.where((b) => b.id != event.article.id).toList();
        emit(state.copyWith(
          bookmarks: rolledBackBookmarks,
          errorMessage: 'Failed to save bookmark: ${failure.message}',
        ));
      },
      (_) {
        // Clear any error message on success
        if (state.errorMessage != null) {
          emit(state.copyWith(errorMessage: null));
        }
      },
    );
  }

  Future<void> _onBookmarkRemoved(
    BookmarkRemoved event,
    Emitter<BookmarksState> emit,
  ) async {
    // Store original for potential rollback
    final removedArticle = state.bookmarks
        .where((b) => b.id == event.articleId)
        .firstOrNull;

    // Optimistically update the UI
    final updatedBookmarks =
        state.bookmarks.where((b) => b.id != event.articleId).toList();
    emit(state.copyWith(bookmarks: updatedBookmarks));

    // Persist to storage
    final result = await _repository.removeBookmark(event.articleId);

    result.fold(
      (failure) {
        // Rollback on failure if we had a valid article
        if (removedArticle != null) {
          final rolledBackBookmarks = [removedArticle, ...state.bookmarks];
          emit(state.copyWith(
            bookmarks: rolledBackBookmarks,
            errorMessage: 'Failed to remove bookmark: ${failure.message}',
          ));
        }
      },
      (_) {
        // Clear any error message on success
        if (state.errorMessage != null) {
          emit(state.copyWith(errorMessage: null));
        }
      },
    );
  }
}
