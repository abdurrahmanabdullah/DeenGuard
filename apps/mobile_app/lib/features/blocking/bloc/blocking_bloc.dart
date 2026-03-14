import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/app_block_service.dart';
import '../../../data/models/blocked_domain_model.dart';
import '../../../core/services/vpn_service.dart';
import '../../../core/services/stats_service.dart';

part 'blocking_event.dart';
part 'blocking_state.dart';

class BlockingBloc extends Bloc<BlockingEvent, BlockingState> {
  BlockingBloc() : super(BlockingInitial()) {
    on<LoadBlockingStatus>(_onLoadBlockingStatus);
    on<ToggleProtection>(_onToggleProtection);
    on<SyncBlockedDomains>(_onSyncBlockedDomains);
    on<AddCustomDomain>(_onAddCustomDomain);
    on<RemoveCustomDomain>(_onRemoveCustomDomain);
    on<LoadSocialMediaSettings>(_onLoadSocialMediaSettings);
    on<UpdateSocialMediaSetting>(_onUpdateSocialMediaSetting);
  }

  Future<void> _onLoadBlockingStatus(
      LoadBlockingStatus event, Emitter<BlockingState> emit) async {
    emit(BlockingLoading());
    try {
      bool? isVpnActive = StorageService.getBool('vpn_active');

      if (isVpnActive == null) {
        isVpnActive = false;
        await StorageService.setBool('vpn_active', false);
      }

      // Check if VPN is actually running, if not but should be, restart it
      if (isVpnActive) {
        final isVpnRunning = await VpnService.checkVpnStatus();
        if (!isVpnRunning) {
          print('[DEBUG] VPN was active but not running, restarting...');
          await VpnService.restartVpn();
        }
      }

      final isAccessibilityActive =
          StorageService.getBool('accessibility_active') ?? false;
      final localDomains = StorageService.getBlockedDomains();
      final socialMediaSettings = StorageService.getSocialMediaSettings();

      emit(BlockingStatusLoaded(
        isVpnActive: isVpnActive,
        isAccessibilityActive: isAccessibilityActive,
        localDomains: localDomains,
        socialMediaSettings: socialMediaSettings,
      ));
    } catch (e) {
      emit(BlockingError(e.toString()));
    }
  }

  Future<void> _onToggleProtection(
      ToggleProtection event, Emitter<BlockingState> emit) async {
    try {
      if (event.enabled) {
        await VpnService.startVpn();
        // Record an initial event to show statistics are working
        await StatsService.recordBlock(
          title: 'DeenGuard Protection System Online',
          type: 'ads',
          iconPath: '',
        );
      } else {
        await VpnService.stopVpn();
      }

      await StorageService.setBool('vpn_active', event.enabled);
      final currentSettings = state is BlockingStatusLoaded
          ? (state as BlockingStatusLoaded).socialMediaSettings
          : <String, bool>{};
      emit(BlockingStatusLoaded(
        isVpnActive: event.enabled,
        isAccessibilityActive: state is BlockingStatusLoaded
            ? (state as BlockingStatusLoaded).isAccessibilityActive
            : false,
        localDomains: state is BlockingStatusLoaded
            ? (state as BlockingStatusLoaded).localDomains
            : [],
        socialMediaSettings: currentSettings,
      ));
    } catch (e) {
      emit(BlockingError(e.toString()));
    }
  }

  Future<void> _onSyncBlockedDomains(
      SyncBlockedDomains event, Emitter<BlockingState> emit) async {
    try {
      final response = await ApiService.get('/blocking/domains');
      final domains = (response.data['domains'] as List)
          .map((d) => BlockedDomain.fromJson(d))
          .toList();

      final domainStrings = domains.map((d) => d.domain).toList();
      await StorageService.setBlockedDomains(domainStrings);

      if (state is BlockingStatusLoaded) {
        final currentSettings = (state as BlockingStatusLoaded).socialMediaSettings;
        emit(BlockingStatusLoaded(
          isVpnActive: (state as BlockingStatusLoaded).isVpnActive,
          isAccessibilityActive:
              (state as BlockingStatusLoaded).isAccessibilityActive,
          localDomains: domainStrings,
          socialMediaSettings: currentSettings,
        ));
      }
    } catch (e) {
      emit(BlockingError(e.toString()));
    }
  }

  Future<void> _onAddCustomDomain(
      AddCustomDomain event, Emitter<BlockingState> emit) async {
    try {
      await ApiService.post('/blocking/domains',
          data: {'domain': event.domain});
      add(SyncBlockedDomains());
    } catch (e) {
      emit(BlockingError(e.toString()));
    }
  }

  Future<void> _onRemoveCustomDomain(
      RemoveCustomDomain event, Emitter<BlockingState> emit) async {
    try {
      await ApiService.delete('/blocking/domains/${event.domainId}');
      add(SyncBlockedDomains());
    } catch (e) {
      emit(BlockingError(e.toString()));
    }
  }

  Future<void> _onLoadSocialMediaSettings(
      LoadSocialMediaSettings event, Emitter<BlockingState> emit) async {
    try {
      print('[DEBUG] _onLoadSocialMediaSettings called');
      final settings = StorageService.getSocialMediaSettings();
      print('[DEBUG] Loaded settings: $settings');
      if (state is BlockingStatusLoaded) {
        print('[DEBUG] Updating existing state');
        emit((state as BlockingStatusLoaded).copyWith(
          socialMediaSettings: settings,
        ));
      } else {
        print('[DEBUG] Creating new state');
        emit(BlockingStatusLoaded(
          isVpnActive: false,
          isAccessibilityActive: false,
          localDomains: [],
          socialMediaSettings: settings,
        ));
      }
    } catch (e) {
      print('[DEBUG] Error loading settings: $e');
      emit(BlockingError(e.toString()));
    }
  }

  Future<void> _onUpdateSocialMediaSetting(
      UpdateSocialMediaSetting event, Emitter<BlockingState> emit) async {
    try {
      print('[DEBUG] _onUpdateSocialMediaSetting called: ${event.key} = ${event.value}');
      
      final currentSettings = StorageService.getSocialMediaSettings();
      print('[DEBUG] Current settings before: $currentSettings');
      
      currentSettings[event.key] = event.value;
      await StorageService.setSocialMediaSettings(currentSettings);
      
      print('[DEBUG] Current settings after: $currentSettings');

      if (event.key == 'fb_app' && event.value) {
        await _blockFacebookDomains();
      } else if (event.key == 'fb_app' && !event.value) {
        await _unblockFacebookDomains();
      }

      print('[DEBUG] Calling AppBlockService.updateAppBlockingSettings...');
      try {
        final appBlockResult = await AppBlockService.updateAppBlockingSettings(
          fbAppBlocked: currentSettings['fb_app'] ?? false,
          fbReelsBlocked: currentSettings['fb_reels'] ?? false,
          ytAppBlocked: currentSettings['yt_app'] ?? false,
          ytShortsBlocked: currentSettings['yt_shorts'] ?? false,
          igAppBlocked: currentSettings['ig_app'] ?? false,
          igReelsBlocked: currentSettings['ig_reels'] ?? false,
        );
        print('[DEBUG] AppBlockService result: $appBlockResult');
      } catch (e) {
        print('[DEBUG] AppBlockService error: $e');
      }

      if (state is BlockingStatusLoaded) {
        print('[DEBUG] Emitting new state with settings: $currentSettings');
        emit((state as BlockingStatusLoaded).copyWith(
          socialMediaSettings: currentSettings,
        ));
      } else {
        print('[DEBUG] State is not BlockingStatusLoaded, creating new state');
        emit(BlockingStatusLoaded(
          isVpnActive: false,
          isAccessibilityActive: false,
          localDomains: [],
          socialMediaSettings: currentSettings,
        ));
      }
    } catch (e) {
      print('[DEBUG] Error: $e');
      emit(BlockingError(e.toString()));
    }
  }

  Future<void> _blockFacebookDomains() async {
    const fbDomains = [
      'facebook.com',
      'www.facebook.com',
      'm.facebook.com',
      'web.facebook.com',
      'connect.facebook.net',
      'graph.facebook.com',
      'staticxx.facebook.com',
    ];
    final currentDomains = StorageService.getBlockedDomains();
    final updatedDomains = {...currentDomains, ...fbDomains}.toList();
    await StorageService.setBlockedDomains(updatedDomains);
  }

  Future<void> _unblockFacebookDomains() async {
    const fbDomains = [
      'facebook.com',
      'www.facebook.com',
      'm.facebook.com',
      'web.facebook.com',
      'connect.facebook.net',
      'graph.facebook.com',
      'staticxx.facebook.com',
    ];
    final currentDomains = StorageService.getBlockedDomains();
    final updatedDomains = currentDomains.where((d) => !fbDomains.contains(d)).toList();
    await StorageService.setBlockedDomains(updatedDomains);
  }
}
