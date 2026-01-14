// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/bookmarks/data/datasources/bookmarks_local_datasource.dart'
    as _i647;
import '../../features/bookmarks/data/repositories/bookmarks_repository_impl.dart'
    as _i1013;
import '../../features/bookmarks/domain/repositories/bookmarks_repository.dart'
    as _i1047;
import '../../features/bookmarks/presentation/bloc/bookmarks_bloc.dart'
    as _i262;
import '../../features/feed/data/datasources/feed_local_datasource.dart'
    as _i827;
import '../../features/feed/data/datasources/feed_remote_datasource.dart'
    as _i1048;
import '../../features/feed/data/datasources/newsletter_scraper.dart' as _i551;
import '../../features/feed/data/repositories/feed_repository_impl.dart'
    as _i452;
import '../../features/feed/domain/repositories/feed_repository.dart' as _i430;
import '../../features/feed/domain/usecases/get_article_by_id.dart' as _i188;
import '../../features/feed/domain/usecases/get_articles.dart' as _i965;
import '../../features/feed/presentation/bloc/feed_bloc.dart' as _i774;
import '../../features/search/presentation/bloc/search_bloc.dart' as _i552;
import '../../features/settings/presentation/bloc/settings_bloc.dart' as _i585;
import '../network/dio_client.dart' as _i667;
import '../network/network_info.dart' as _i932;
import '../storage/local_storage.dart' as _i329;
import 'injection.dart' as _i464;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    final dioModule = _$DioModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.factory<_i585.SettingsBloc>(() => _i585.SettingsBloc());
    gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i361.Dio>(() => dioModule.dio);
    gh.lazySingleton<_i551.NewsletterScraper>(
      () => _i551.NewsletterScraperImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i329.LocalStorage>(
      () => _i329.LocalStorageImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i827.FeedLocalDataSource>(
      () => _i827.FeedLocalDataSourceImpl(gh<_i329.LocalStorage>()),
    );
    gh.lazySingleton<_i647.BookmarksLocalDataSource>(
      () => _i647.BookmarksLocalDataSourceImpl(gh<_i329.LocalStorage>()),
    );
    gh.lazySingleton<_i932.NetworkInfo>(
      () => _i932.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i1048.FeedRemoteDataSource>(
      () => _i1048.FeedRemoteDataSourceImpl(
        gh<_i361.Dio>(),
        gh<_i551.NewsletterScraper>(),
      ),
    );
    gh.lazySingleton<_i1047.BookmarksRepository>(
      () =>
          _i1013.BookmarksRepositoryImpl(gh<_i647.BookmarksLocalDataSource>()),
    );
    gh.lazySingleton<_i430.FeedRepository>(
      () => _i452.FeedRepositoryImpl(
        gh<_i1048.FeedRemoteDataSource>(),
        gh<_i827.FeedLocalDataSource>(),
        gh<_i932.NetworkInfo>(),
      ),
    );
    gh.factory<_i188.GetArticleById>(
      () => _i188.GetArticleById(gh<_i430.FeedRepository>()),
    );
    gh.factory<_i965.GetArticles>(
      () => _i965.GetArticles(gh<_i430.FeedRepository>()),
    );
    gh.factory<_i262.BookmarksBloc>(
      () => _i262.BookmarksBloc(gh<_i1047.BookmarksRepository>()),
    );
    gh.factory<_i774.FeedBloc>(
      () => _i774.FeedBloc(
        gh<_i965.GetArticles>(),
        gh<_i430.FeedRepository>(),
        gh<_i932.NetworkInfo>(),
      ),
    );
    gh.factory<_i552.SearchBloc>(
      () => _i552.SearchBloc(
        gh<_i430.FeedRepository>(),
        gh<_i329.LocalStorage>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i464.RegisterModule {}

class _$DioModule extends _i667.DioModule {}
