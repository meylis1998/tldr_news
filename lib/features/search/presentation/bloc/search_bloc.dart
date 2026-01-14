import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tldr_news/core/constants/app_constants.dart';
import 'package:tldr_news/core/storage/local_storage.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';
import 'package:tldr_news/features/feed/domain/repositories/feed_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._repository, this._localStorage) : super(const SearchState()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchSubmitted>(_onSearchSubmitted);
    on<SearchCleared>(_onSearchCleared);
    on<RecentSearchRemoved>(_onRecentSearchRemoved);
    on<RecentSearchesLoaded>(_onRecentSearchesLoaded);
  }

  final FeedRepository _repository;
  final LocalStorage _localStorage;
  Timer? _debounceTimer;

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(query: event.query));

    if (event.query.isEmpty) {
      emit(state.copyWith(
        status: SearchStatus.initial,
        results: [],
      ));
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(AppConstants.searchDebounce, () {
      add(SearchSubmitted());
    });
  }

  Future<void> _onSearchSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    if (state.query.isEmpty) return;

    emit(state.copyWith(status: SearchStatus.loading));

    final result = await _repository.searchArticles(state.query);

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => throw StateError('unreachable'));
      emit(state.copyWith(
        status: SearchStatus.error,
        errorMessage: failure.message,
      ));
      return;
    }

    final articles = result.fold((l) => throw StateError('unreachable'), (r) => r);
    emit(state.copyWith(
      status: SearchStatus.loaded,
      results: articles,
    ));

    final recentSearches = [...state.recentSearches];
    if (!recentSearches.contains(state.query)) {
      recentSearches.insert(0, state.query);
      if (recentSearches.length > AppConstants.maxRecentSearches) {
        recentSearches.removeLast();
      }
      await _localStorage.saveRecentSearches(recentSearches);
      emit(state.copyWith(recentSearches: recentSearches));
    }
  }

  void _onSearchCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(
      query: '',
      status: SearchStatus.initial,
      results: [],
    ));
  }

  Future<void> _onRecentSearchRemoved(
    RecentSearchRemoved event,
    Emitter<SearchState> emit,
  ) async {
    final recentSearches = state.recentSearches
        .where((s) => s != event.search)
        .toList();
    await _localStorage.saveRecentSearches(recentSearches);
    emit(state.copyWith(recentSearches: recentSearches));
  }

  Future<void> _onRecentSearchesLoaded(
    RecentSearchesLoaded event,
    Emitter<SearchState> emit,
  ) async {
    final recentSearches = await _localStorage.getRecentSearches();
    emit(state.copyWith(recentSearches: recentSearches));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
