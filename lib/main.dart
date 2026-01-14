import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tldr_news/app.dart';
import 'package:tldr_news/core/di/injection.dart';
import 'package:tldr_news/features/bookmarks/presentation/bloc/bookmarks_bloc.dart';
import 'package:tldr_news/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:tldr_news/features/settings/presentation/bloc/settings_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final appDocDir = await getApplicationDocumentsDirectory();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(appDocDir.path),
  );

  await configureDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<FeedBloc>(
          create: (_) => getIt<FeedBloc>()..add(const FeedLoadRequested()),
        ),
        BlocProvider<BookmarksBloc>(
          create: (_) => getIt<BookmarksBloc>()..add(const BookmarksLoadRequested()),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => getIt<SettingsBloc>(),
        ),
      ],
      child: const TldrNewsApp(),
    ),
  );
}
