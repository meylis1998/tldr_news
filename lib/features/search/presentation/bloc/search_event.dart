part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class SearchSubmitted extends SearchEvent {
  const SearchSubmitted();
}

class SearchCleared extends SearchEvent {
  const SearchCleared();
}

class RecentSearchRemoved extends SearchEvent {
  const RecentSearchRemoved(this.search);

  final String search;

  @override
  List<Object?> get props => [search];
}

class RecentSearchesLoaded extends SearchEvent {
  const RecentSearchesLoaded();
}
