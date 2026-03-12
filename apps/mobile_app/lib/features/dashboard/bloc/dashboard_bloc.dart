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
      emit(DashboardLoaded(
        blockedDomainsCount: response.data['blockedDomainsCount'] ?? 0,
        blockedAppsCount: response.data['blockedAppsCount'] ?? 0,
        blocksToday: response.data['blocksToday'] ?? 0,
        isProtectionActive: response.data['isProtectionActive'] ?? false,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(RefreshDashboard event, Emitter<DashboardState> emit) async {
    try {
      final response = await ApiService.get('/dashboard');
      emit(DashboardLoaded(
        blockedDomainsCount: response.data['blockedDomainsCount'] ?? 0,
        blockedAppsCount: response.data['blockedAppsCount'] ?? 0,
        blocksToday: response.data['blocksToday'] ?? 0,
        isProtectionActive: response.data['isProtectionActive'] ?? false,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
