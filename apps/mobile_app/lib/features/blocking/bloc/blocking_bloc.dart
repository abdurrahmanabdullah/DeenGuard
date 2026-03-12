import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/blocked_domain_model.dart';
import '../../../core/services/vpn_service.dart';

part 'blocking_event.dart';
part 'blocking_state.dart';

class BlockingBloc extends Bloc<BlockingEvent, BlockingState> {
  BlockingBloc() : super(BlockingInitial()) {
    on<LoadBlockingStatus>(_onLoadBlockingStatus);
    on<ToggleProtection>(_onToggleProtection);
    on<SyncBlockedDomains>(_onSyncBlockedDomains);
    on<AddCustomDomain>(_onAddCustomDomain);
    on<RemoveCustomDomain>(_onRemoveCustomDomain);
  }

  Future<void> _onLoadBlockingStatus(
      LoadBlockingStatus event, Emitter<BlockingState> emit) async {
    emit(BlockingLoading());
    try {
      final isVpnActive = StorageService.getBool('vpn_active') ?? false;
      final isAccessibilityActive =
          StorageService.getBool('accessibility_active') ?? false;
      final localDomains = StorageService.getBlockedDomains();

      emit(BlockingStatusLoaded(
        isVpnActive: isVpnActive,
        isAccessibilityActive: isAccessibilityActive,
        localDomains: localDomains,
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
      } else {
        await VpnService.stopVpn();
      }

      await StorageService.setBool('vpn_active', event.enabled);
      emit(BlockingStatusLoaded(
        isVpnActive: event.enabled,
        isAccessibilityActive: state is BlockingStatusLoaded
            ? (state as BlockingStatusLoaded).isAccessibilityActive
            : false,
        localDomains: state is BlockingStatusLoaded
            ? (state as BlockingStatusLoaded).localDomains
            : [],
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
        emit(BlockingStatusLoaded(
          isVpnActive: (state as BlockingStatusLoaded).isVpnActive,
          isAccessibilityActive:
              (state as BlockingStatusLoaded).isAccessibilityActive,
          localDomains: domainStrings,
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
}
