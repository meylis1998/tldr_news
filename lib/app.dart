import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tldr_news/core/router/app_router.dart';
import 'package:tldr_news/core/theme/app_theme.dart';
import 'package:tldr_news/features/settings/presentation/bloc/settings_bloc.dart';

class TldrNewsApp extends StatelessWidget {
  const TldrNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return MaterialApp.router(
              title: 'TLDR News',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: state.themeMode,
              routerConfig: appRouter,
            );
          },
        );
      },
    );
  }
}
