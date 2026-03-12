import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../../blocking/bloc/blocking_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  int _adsBlocked = 0;
  int _sitesBlocked = 0;
  Timer? _mockTimer;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboard());
  }

  @override
  void dispose() {
    _mockTimer?.cancel();
    super.dispose();
  }

  void _manageTimer(bool isProtected) {
    if (isProtected && _mockTimer == null) {
      // Start simulating blocks every few seconds for demonstration
      _mockTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
        if (mounted) {
          setState(() {
            _adsBlocked += 1;
            if (timer.tick % 5 == 0) {
              _sitesBlocked += 1;
              print(
                  'DeenGuard Secure: 🛡️ Blocked adult/harmful content request.');
            } else {
              print(
                  'DeenGuard Secure: 🛡️ Blocked ad/tracker request from background app.');
            }
          });
        }
      });
    } else if (!isProtected && _mockTimer != null) {
      _mockTimer?.cancel();
      _mockTimer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<BlockingBloc>(),
      child: BlocListener<BlockingBloc, BlockingState>(
        listener: (context, state) {
          if (state is BlockingStatusLoaded) {
            _manageTimer(state.isVpnActive);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('DeenGuard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.power_settings_new, color: Colors.red),
                tooltip: 'Exit App',
                onPressed: () async {
                  final shouldExit = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Exit DeenGuard'),
                      content: const Text('Are you sure you want to exit the app?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            'Exit',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (shouldExit == true) {
                    exit(0);
                  }
                },
              ),
            ],
          ),
          body: _buildBody(),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.security),
                label: 'Protection',
              ),
              NavigationDestination(
                icon: Icon(Icons.analytics_outlined),
                label: 'Statistics',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 1) {
      return _buildStatisticsView();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(),
          const SizedBox(height: 24),
          _buildQuickStatsCard(),
          const SizedBox(height: 24),
          Text(
            'Recent Activity (Live Console)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildActivityList(),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    return BlocBuilder<BlockingBloc, BlockingState>(
      builder: (context, state) {
        bool isProtected = false; // Default to false — protection starts disabled
        bool isLoading = state is BlockingLoading;

        if (state is BlockingStatusLoaded) {
          isProtected = state.isVpnActive;
        }

        return Card(
          elevation: 4,
          color: isProtected
              ? AppColors.primary
              : Colors.orange[700],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(
                  isProtected ? Icons.shield : Icons.gpp_maybe,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isProtected
                            ? 'You are Protected'
                            : 'Protection Disabled',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isProtected
                            ? 'DeenGuard DNS is actively filtering.'
                            : 'Tap below to enable protection.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  Switch(
                    value: isProtected,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.green[300],
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.orange[400],
                    onChanged: (value) {
                      context.read<BlockingBloc>().add(ToggleProtection(value));
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStatsCard() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.block,
                      color: Theme.of(context).primaryColor, size: 32),
                  const SizedBox(height: 8),
                  Text('$_adsBlocked',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text('Ads Blocked',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 32),
                  const SizedBox(height: 8),
                  Text('$_sitesBlocked',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text('Harmful Sites',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityList() {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final items = [
            {
              'title': 'Blocked trackers from facebook.com',
              'time': '2 mins ago',
              'icon': Icons.track_changes
            },
            {
              'title': 'Blocked access to known adult site',
              'time': '1 hour ago',
              'icon': Icons.warning
            },
            {
              'title': 'Updated blocking rules',
              'time': '3 hours ago',
              'icon': Icons.update
            },
          ];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(items[index]['icon'] as IconData,
                  color: Theme.of(context).primaryColor, size: 20),
            ),
            title: Text(items[index]['title'] as String,
                style: const TextStyle(fontSize: 14)),
            subtitle: Text(items[index]['time'] as String,
                style: const TextStyle(fontSize: 12)),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(),
          const SizedBox(height: 24),
          Text(
            'Threats Blocked over Time',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                List<int> threatsOverTime = [0, 0, 0, 0, 0, 0, 0];
                if (state is DashboardLoaded) {
                  threatsOverTime = state.threatsOverTime;
                }

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (threatsOverTime.reduce((a, b) => a > b ? a : b) +
                                5)
                            .toDouble(),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => Colors.blueGrey,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${rod.toY.round()}',
                                const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = [
                                  'Mon',
                                  'Tue',
                                  'Wed',
                                  'Thu',
                                  'Fri',
                                  'Sat',
                                  'Sun'
                                ];
                                if (value.toInt() >= 0 &&
                                    value.toInt() < days.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(days[value.toInt()],
                                        style: const TextStyle(fontSize: 12)),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(
                                showTitles:
                                    false), // Hide left axis to look cleaner
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(
                          threatsOverTime.length,
                          (index) => BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: threatsOverTime[index].toDouble(),
                                color: index == threatsOverTime.length - 1
                                    ? Theme.of(context).primaryColor
                                    : Colors.orange,
                                width: 20,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildQuickStatsCard(),
          const SizedBox(height: 24),
          Text(
            'Threat Types',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                Map<String, int> threatTypes = {
                  'Ads & Trackers': 0,
                  'Adult Content': 0,
                  'Gambling': 0,
                };

                if (state is DashboardLoaded) {
                  if (state.threatTypes.isNotEmpty) {
                    threatTypes = state.threatTypes;
                  }
                }

                final entries = threatTypes.entries.toList();

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: List.generate(entries.length, (index) {
                      final entry = entries[index];
                      Color color = Colors.blue;
                      if (entry.key.toLowerCase().contains('adult')) {
                        color = Colors.red;
                      } else if (entry.key.toLowerCase().contains('gambling')) {
                        color = Colors.purple;
                      }

                      return Column(
                        children: [
                          _buildThreatRow(entry.key, entry.value, color),
                          if (index < entries.length - 1) const Divider(),
                        ],
                      );
                    }),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildThreatRow(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Text(count.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
