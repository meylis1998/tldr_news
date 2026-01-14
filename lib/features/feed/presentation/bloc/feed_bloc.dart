import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tldr_news/core/network/network_info.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';
import 'package:tldr_news/features/feed/domain/usecases/get_articles.dart';

part 'feed_event.dart';
part 'feed_state.dart';

@injectable
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc(this._getArticles, this._networkInfo) : super(const FeedState()) {
    on<FeedLoadRequested>(_onLoadRequested);
    on<FeedRefreshRequested>(_onRefreshRequested);
    on<FeedCategoryChanged>(_onCategoryChanged);
    on<FeedArticleRead>(_onArticleRead);

    _networkInfo.onConnectivityChanged.listen((isConnected) {
      if (isConnected && state.isOffline) {
        add(FeedRefreshRequested());
      }
    });
  }

  final GetArticles _getArticles;
  final NetworkInfo _networkInfo;

  Future<void> _onLoadRequested(
    FeedLoadRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(status: FeedStatus.loading));

    final isConnected = await _networkInfo.isConnected;
    final result = await _getArticles(category: event.category);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: FeedStatus.error,
          errorMessage: failure.message,
          isOffline: !isConnected,
        ),
      ),
      (articles) => emit(
        state.copyWith(
          status: FeedStatus.loaded,
          articles: articles,
          selectedCategory: event.category,
          isOffline: !isConnected,
        ),
      ),
    );
  }

  Future<void> _onRefreshRequested(
    FeedRefreshRequested event,
    Emitter<FeedState> emit,
  ) async {
    final isConnected = await _networkInfo.isConnected;
    final result = await _getArticles(
      category: state.selectedCategory,
      forceRefresh: true,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: failure.message,
          isOffline: !isConnected,
        ),
      ),
      (articles) => emit(
        state.copyWith(
          status: FeedStatus.loaded,
          articles: articles,
          isOffline: !isConnected,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onCategoryChanged(
    FeedCategoryChanged event,
    Emitter<FeedState> emit,
  ) async {
    if (event.category == state.selectedCategory) return;

    emit(state.copyWith(
      status: FeedStatus.loading,
      selectedCategory: event.category,
    ));

    final isConnected = await _networkInfo.isConnected;
    final result = await _getArticles(category: event.category);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: FeedStatus.error,
          errorMessage: failure.message,
          isOffline: !isConnected,
        ),
      ),
      (articles) => emit(
        state.copyWith(
          status: FeedStatus.loaded,
          articles: articles,
          isOffline: !isConnected,
        ),
      ),
    );
  }

  void _onArticleRead(
    FeedArticleRead event,
    Emitter<FeedState> emit,
  ) {
    final updatedArticles = state.articles.map((article) {
      if (article.id == event.articleId) {
        return article.copyWith(isRead: true);
      }
      return article;
    }).toList();

    emit(state.copyWith(articles: updatedArticles));
  }
}
