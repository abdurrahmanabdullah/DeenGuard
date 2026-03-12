import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/storage_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdateNotifications>(_onUpdateNotifications);
    on<UpdateAutoSync>(_onUpdateAutoSync);
    on<ClearCache>(_onClearCache);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final themeMode = StorageService.getString('theme_mode') ?? 'system';
      final notificationsEnabled = StorageService.getBool('notifications_enabled') ?? true;
      final autoSyncEnabled = StorageService.getBool('auto_sync_enabled') ?? true;
      
      emit(SettingsLoaded(
        themeMode: themeMode,
        notificationsEnabled: notificationsEnabled,
        autoSyncEnabled: autoSyncEnabled,
      ));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateThemeMode(UpdateThemeMode event, Emitter<SettingsState> emit) async {
    await StorageService.setString('theme_mode', event.themeMode);
    if (state is SettingsLoaded) {
      emit(SettingsLoaded(
        themeMode: event.themeMode,
        notificationsEnabled: (state as SettingsLoaded).notificationsEnabled,
        autoSyncEnabled: (state as SettingsLoaded).autoSyncEnabled,
      ));
    }
  }

  Future<void> _onUpdateNotifications(UpdateNotifications event, Emitter<SettingsState> emit) async {
    await StorageService.setBool('notifications_enabled', event.enabled);
    if (state is SettingsLoaded) {
      emit(SettingsLoaded(
        themeMode: (state as SettingsLoaded).themeMode,
        notificationsEnabled: event.enabled,
        autoSyncEnabled: (state as SettingsLoaded).autoSyncEnabled,
      ));
    }
  }

  Future<void> _onUpdateAutoSync(UpdateAutoSync event, Emitter<SettingsState> emit) async {
    await StorageService.setBool('auto_sync_enabled', event.enabled);
    if (state is SettingsLoaded) {
      emit(SettingsLoaded(
        themeMode: (state as SettingsLoaded).themeMode,
        notificationsEnabled: (state as SettingsLoaded).notificationsEnabled,
        autoSyncEnabled: event.enabled,
      ));
    }
  }

  Future<void> _onClearCache(ClearCache event, Emitter<SettingsState> emit) async {
    await StorageService.clear();
    add(LoadSettings());
  }
}
