import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

part 'settings_event.dart';
part 'settings_state.dart';

@injectable
class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<ThemeModeChanged>(_onThemeModeChanged);
    on<NotificationsToggled>(_onNotificationsToggled);
    on<DefaultCategoryChanged>(_onDefaultCategoryChanged);
  }

  void _onThemeModeChanged(
    ThemeModeChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(themeMode: event.themeMode));
  }

  void _onNotificationsToggled(
    NotificationsToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(notificationsEnabled: event.enabled));
  }

  void _onDefaultCategoryChanged(
    DefaultCategoryChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(defaultCategory: event.category));
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    try {
      return SettingsState(
        themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
        defaultCategory: json['defaultCategory'] as String? ?? 'all',
      );
    } catch (_) {
      return const SettingsState();
    }
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    return {
      'themeMode': state.themeMode.index,
      'notificationsEnabled': state.notificationsEnabled,
      'defaultCategory': state.defaultCategory,
    };
  }
}
