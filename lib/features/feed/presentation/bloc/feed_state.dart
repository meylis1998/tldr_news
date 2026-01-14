part of 'feed_bloc.dart';

enum FeedStatus { initial, loading, loaded, error }

class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.articles = const [],
    this.selectedCategory = 'tech',
    this.errorMessage,
    this.isOffline = false,
  });

  final FeedStatus status;
  final List<Article> articles;
  final String selectedCategory;
  final String? errorMessage;
  final bool isOffline;

  FeedState copyWith({
    FeedStatus? status,
    List<Article>? articles,
    String? selectedCategory,
    String? errorMessage,
    bool? isOffline,
  }) {
    return FeedState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [
        status,
        articles,
        selectedCategory,
        errorMessage,
        isOffline,
      ];
}
