part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.defaultCategory = 'all',
  });

  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final String defaultCategory;

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    String? defaultCategory,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultCategory: defaultCategory ?? this.defaultCategory,
    );
  }

  @override
  List<Object?> get props => [themeMode, notificationsEnabled, defaultCategory];
}
