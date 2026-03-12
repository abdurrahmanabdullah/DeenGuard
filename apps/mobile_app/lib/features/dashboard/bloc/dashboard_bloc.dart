import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/api_service.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final response = await ApiService.get('/dashboard');
      final data = response.data;
      emit(DashboardLoaded(
        blockedDomainsCount: data['blockedDomainsCount'] ?? 0,
        blockedAppsCount: data['blockedAppsCount'] ?? 0,
        blocksToday: data['blocksToday'] ?? 0,
        isProtectionActive: data['isProtectionActive'] ?? false,
        threatsOverTime: List<int>.from(data['threatsOverTime'] ?? [0, 0, 0, 0, 0, 0, 0]),
        threatTypes: Map<String, int>.from(data['threatTypes'] ?? {}),
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(RefreshDashboard event, Emitter<DashboardState> emit) async {
    try {
      final response = await ApiService.get('/dashboard');
      final data = response.data;
      emit(DashboardLoaded(
        blockedDomainsCount: data['blockedDomainsCount'] ?? 0,
        blockedAppsCount: data['blockedAppsCount'] ?? 0,
        blocksToday: data['blocksToday'] ?? 0,
        isProtectionActive: data['isProtectionActive'] ?? false,
        threatsOverTime: List<int>.from(data['threatsOverTime'] ?? [0, 0, 0, 0, 0, 0, 0]),
        threatTypes: Map<String, int>.from(data['threatTypes'] ?? {}),
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
