part of 'search_bloc.dart';

enum SearchStatus { initial, loading, loaded, error }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.results = const [],
    this.recentSearches = const [],
    this.errorMessage,
  });

  final SearchStatus status;
  final String query;
  final List<Article> results;
  final List<String> recentSearches;
  final String? errorMessage;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<Article>? results,
    List<String>? recentSearches,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, query, results, recentSearches, errorMessage];
}
