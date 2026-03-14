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
  final List<int> threatsOverTime;
  final Map<String, int> threatTypes;
  final List<Map<String, dynamic>> activityFeed;

  const DashboardLoaded({
    required this.blockedDomainsCount,
    required this.blockedAppsCount,
    required this.blocksToday,
    required this.isProtectionActive,
    required this.threatsOverTime,
    required this.threatTypes,
    this.activityFeed = const [],
  });

  @override
  List<Object?> get props => [
        blockedDomainsCount,
        blockedAppsCount,
        blocksToday,
        isProtectionActive,
        threatsOverTime,
        threatTypes,
        activityFeed,
      ];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
