part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class ThemeModeChanged extends SettingsEvent {
  const ThemeModeChanged(this.themeMode);

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}

class NotificationsToggled extends SettingsEvent {
  const NotificationsToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

class DefaultCategoryChanged extends SettingsEvent {
  const DefaultCategoryChanged(this.category);

  final String category;

  @override
  List<Object?> get props => [category];
}
