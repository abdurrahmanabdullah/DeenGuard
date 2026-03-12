part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}
class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final String themeMode;
  final bool notificationsEnabled;
  final bool autoSyncEnabled;

  const SettingsLoaded({
    required this.themeMode,
    required this.notificationsEnabled,
    required this.autoSyncEnabled,
  });

  @override
  List<Object?> get props => [themeMode, notificationsEnabled, autoSyncEnabled];
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
  @override
  List<Object?> get props => [message];
}
