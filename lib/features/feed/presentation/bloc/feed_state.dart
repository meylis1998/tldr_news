part of 'feed_bloc.dart';

enum FeedStatus { initial, loading, loaded, error }

class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.articles = const [],
    this.groupedArticles = const {},
    this.selectedCategory = 'all',
    this.errorMessage,
    this.isOffline = false,
  });

  final FeedStatus status;
  final List<Article> articles;
  final Map<String, List<Article>> groupedArticles;
  final String selectedCategory;
  final String? errorMessage;
  final bool isOffline;

  bool get isAllCategory => selectedCategory == 'all';

  FeedState copyWith({
    FeedStatus? status,
    List<Article>? articles,
    Map<String, List<Article>>? groupedArticles,
    String? selectedCategory,
    String? errorMessage,
    bool? isOffline,
  }) {
    return FeedState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      groupedArticles: groupedArticles ?? this.groupedArticles,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [
        status,
        articles,
        groupedArticles,
        selectedCategory,
        errorMessage,
        isOffline,
      ];
}
