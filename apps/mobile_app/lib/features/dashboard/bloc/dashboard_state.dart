part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int blockedDomainsCount;
  final int blockedAppsCount;
  final int blocksToday;
  final bool isProtectionActive;

  const DashboardLoaded({
    required this.blockedDomainsCount,
    required this.blockedAppsCount,
    required this.blocksToday,
    required this.isProtectionActive,
  });

  @override
  List<Object?> get props => [blockedDomainsCount, blockedAppsCount, blocksToday, isProtectionActive];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
