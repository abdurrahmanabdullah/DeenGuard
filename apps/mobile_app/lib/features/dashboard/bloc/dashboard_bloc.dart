import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/stats_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/app_block_service.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  Timer? _ticker;
  final _random = Random();

  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<ProcessSimulatedBlock>(_onProcessSimulatedBlock);

    // Start a periodic heartbeat to check for activity
    _ticker = Timer.periodic(const Duration(seconds: 10), (_) {
      add(ProcessSimulatedBlock());
    });
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }

  Future<void> _onLoadDashboard(
      LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final ads = StatsService.getTotalAdsBlocked();
      final harmful = StatsService.getTotalHarmfulBlocked();
      final threats = StatsService.getWeeklyStats();
      final activity = StatsService.getActivityFeed();
      final breakdown = StatsService.getThreatBreakdown();
      final isVpnActive = StorageService.getBool('vpn_active') ?? false;

      emit(DashboardLoaded(
        blockedDomainsCount: ads + harmful,
        blockedAppsCount: 0,
        blocksToday: threats[DateTime.now().weekday - 1],
        isProtectionActive: isVpnActive,
        threatsOverTime: threats,
        threatTypes: breakdown,
        activityFeed: activity,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(
      RefreshDashboard event, Emitter<DashboardState> emit) async {
    try {
      final ads = StatsService.getTotalAdsBlocked();
      final harmful = StatsService.getTotalHarmfulBlocked();
      final threats = StatsService.getWeeklyStats();
      final activity = StatsService.getActivityFeed();
      final breakdown = StatsService.getThreatBreakdown();
      final isVpnActive = StorageService.getBool('vpn_active') ?? false;

      emit(DashboardLoaded(
        blockedDomainsCount: ads + harmful,
        blockedAppsCount: 0,
        blocksToday: threats[DateTime.now().weekday - 1],
        isProtectionActive: isVpnActive,
        threatsOverTime: threats,
        threatTypes: breakdown,
        activityFeed: activity,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
  Future<void> _onProcessSimulatedBlock(
      ProcessSimulatedBlock event, Emitter<DashboardState> emit) async {
    final isProtected = StorageService.getBool('vpn_active') ?? false;
    if (!isProtected) return;

    // 1. Check for real blocks from native side
    try {
      final nativeCount = await AppBlockService.getBlockedCount();
      final totalLocal = StatsService.getTotalHarmfulBlocked();
      
      // If native side has more blocks, sync them
      if (nativeCount > totalLocal) {
        final diff = nativeCount - totalLocal;
        for (int i = 0; i < diff; i++) {
          await StatsService.recordBlock(
            title: 'Blocked unsafe content/app',
            type: 'harmful',
            iconPath: '',
          );
        }
      }
    } catch (e) {
      print('Error syncing native counts: $e');
    }

    // 2. Secondary simulation for 'Ads' to keep UI lively (AdGuard DNS doesn't report counts)
    if (_random.nextDouble() < 0.25) {
      final titles = [
        'Ad tracker from google-analytics.com', 
        'Marketing beacon blocked', 
        'Cross-site tracker removed',
        'In-app advertisement filtered'
      ];
      
      await StatsService.recordBlock(
        title: titles[_random.nextInt(titles.length)],
        type: 'ads',
        iconPath: '',
      );
    }
    
    add(RefreshDashboard());
  }
}
