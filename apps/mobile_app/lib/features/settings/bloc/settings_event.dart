part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}
class UpdateThemeMode extends SettingsEvent {
  final String themeMode;
  const UpdateThemeMode(this.themeMode);
  @override
  List<Object?> get props => [themeMode];
}
class UpdateNotifications extends SettingsEvent {
  final bool enabled;
  const UpdateNotifications(this.enabled);
  @override
  List<Object?> get props => [enabled];
}
class UpdateAutoSync extends SettingsEvent {
  final bool enabled;
  const UpdateAutoSync(this.enabled);
  @override
  List<Object?> get props => [enabled];
}
class ClearCache extends SettingsEvent {}
