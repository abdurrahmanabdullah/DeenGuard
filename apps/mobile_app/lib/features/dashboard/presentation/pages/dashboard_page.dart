import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../../blocking/bloc/blocking_bloc.dart';
import 'focus_mode_page.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
const _bg = Color(0xFF0D1117);
const _surface = Color(0xFF161B22);
const _surfaceElevated = Color(0xFF1C232B);
const _emerald = Color(0xFF00E676);
const _emeraldDim = Color(0xFF00C853);
const _emeraldGlow = Color(0x2200E676);
const _textPrimary = Color(0xFFE6EDF3);
const _textSecondary = Color(0xFF8B949E);
const _textMuted = Color(0xFF484F58);
const _amber = Color(0xFFFFB300);
const _coral = Color(0xFFFF5370);
const _blue = Color(0xFF58A6FF);
const _border = Color(0xFF21262D);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboard());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<BlockingBloc>(),
      child: BlocListener<BlockingBloc, BlockingState>(
        listener: (context, state) {},
        child: Scaffold(
          backgroundColor: _bg,
          appBar: _buildAppBar(),
          body: FadeTransition(opacity: _fadeAnim, child: _buildBody()),
          bottomNavigationBar: _buildNavBar(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_emerald, _emeraldDim],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shield_rounded, color: _bg, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'DeenGuard',
            style: TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: _surfaceElevated,
            shape: BoxShape.circle,
            border: Border.all(color: _border),
          ),
          child: IconButton(
            icon: const Icon(Icons.person_outline_rounded,
                color: _textSecondary, size: 20),
            onPressed: () {},
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
      ],
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(top: BorderSide(color: _border, width: 1)),
      ),
      child: NavigationBar(
        height: 72,
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        indicatorColor: _emeraldGlow,
        destinations: [
          _navDest(Icons.shield_rounded, Icons.shield_outlined, 'Protection'),
          _navDest(
              Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Analytics'),
          _navDest(Icons.tune_rounded, Icons.tune_outlined, 'Settings'),
        ],
      ),
    );
  }

  NavigationDestination _navDest(IconData sel, IconData unsel, String label) {
    return NavigationDestination(
      icon: Icon(unsel, color: _textMuted, size: 22),
      selectedIcon: Icon(sel, color: _emerald, size: 22),
      label: label,
    );
  }

  Widget _buildBody() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (_selectedIndex == 1) return _buildStatisticsView(state);
        if (_selectedIndex == 2) return _buildComingSoon('Settings');
        return _buildProtectionView(state);
      },
    );
  }

  Widget _buildComingSoon(String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
                color: _surfaceElevated, shape: BoxShape.circle),
            child: const Icon(Icons.construction_rounded,
                color: _textMuted, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            '$label Coming Soon',
            style: const TextStyle(
                color: _textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildProtectionView(DashboardState state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHero(),
          const SizedBox(height: 32),
          _sectionLabel('PROTECTION MODULES'),
          const SizedBox(height: 14),
          _buildModuleCard(
            title: 'Clean Internet',
            description: 'Ads, trackers & harmful sites filtered',
            icon: Icons.vpn_lock_rounded,
            accentColor: _emerald,
            gradientColors: const [Color(0xFF004D40), Color(0xFF00251A)],
            onTap: () {},
          ),
          _buildModuleCard(
            title: 'Focus Mode',
            description: 'Block Reels, Shorts & distractions',
            icon: Icons.center_focus_strong_rounded,
            accentColor: _amber,
            gradientColors: const [Color(0xFF3E2723), Color(0xFF1B0000)],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FocusModePage()),
            ),
          ),
          const SizedBox(height: 32),
          _sectionLabel('LIVE ACTIVITY'),
          const SizedBox(height: 14),
          _buildActivityFeed(state),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _textMuted,
        letterSpacing: 1.6,
      ),
    );
  }

  Widget _buildStatusHero() {
    return BlocBuilder<BlockingBloc, BlockingState>(
      builder: (context, blockingState) {
        final isProtected = blockingState is BlockingStatusLoaded
            ? blockingState.isVpnActive
            : false;
        final isLoading = blockingState is BlockingLoading;

        return BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, dashboardState) {
            final stats = dashboardState is DashboardLoaded
                ? dashboardState
                : null;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isProtected ? _emerald.withOpacity(0.3) : _border,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isProtected
                        ? _emerald.withOpacity(0.08)
                        : Colors.transparent,
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, __) => Opacity(
                          opacity: isProtected ? _pulseAnim.value : 1.0,
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isProtected
                                  ? _emeraldGlow
                                  : _coral.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isProtected
                                    ? _emerald.withOpacity(0.4)
                                    : _coral.withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              isProtected
                                  ? Icons.verified_user_rounded
                                  : Icons.gpp_bad_rounded,
                              size: 34,
                              color: isProtected ? _emerald : _coral,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isProtected ? 'Protected' : 'Not Protected',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: isProtected ? _emerald : _coral,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isProtected
                                  ? 'All filters active & running'
                                  : 'Enable protection below',
                              style: const TextStyle(
                                fontSize: 13,
                                color: _textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _emerald,
                          ),
                        )
                      else
                        _buildToggle(isProtected, context),
                    ],
                  ),
                  if (isProtected) ...[
                    const SizedBox(height: 20),
                    Container(
                      height: 1,
                      color: _border,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildHeroStat(
                            '${stats?.blockedDomainsCount ?? 0}',
                            'Total Blocked',
                            _emerald),
                        _buildHeroStatDivider(),
                        _buildHeroStat(
                            '${stats?.threatTypes['Harmful Sites'] ?? 0}',
                            'Harmful Sites',
                            _coral),
                        _buildHeroStatDivider(),
                        _buildHeroStat('99.8%', 'Uptime', _blue),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeroStatDivider() {
    return Container(
        width: 1,
        height: 36,
        color: _border,
        margin: const EdgeInsets.symmetric(horizontal: 16));
  }

  Widget _buildHeroStat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: _textMuted,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildToggle(bool isProtected, BuildContext ctx) {
    return GestureDetector(
      onTap: () => ctx.read<BlockingBloc>().add(ToggleProtection(!isProtected)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 52,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isProtected ? _emerald.withOpacity(0.2) : _surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isProtected ? _emerald.withOpacity(0.6) : _border),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment: isProtected ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isProtected ? _emerald : _textMuted,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          splashColor: accentColor.withOpacity(0.05),
          highlightColor: accentColor.withOpacity(0.03),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accentColor.withOpacity(0.2)),
                  ),
                  child: Icon(icon, color: accentColor, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                            fontSize: 13, color: _textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _border),
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      color: _textMuted, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityFeed(DashboardState state) {
    final activities = state is DashboardLoaded ? state.activityFeed : [];

    if (activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _border),
        ),
        child: const Center(
          child: Text(
            'No recent activity',
            style: TextStyle(color: _textMuted, fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: List.generate(activities.length, (i) {
          final item = activities[i];
          final isLast = i == activities.length - 1;
          final color = item['type'] == 'ads' ? _blue : _coral;

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.2)),
                      ),
                      child: Icon(
                        item['type'] == 'ads'
                            ? Icons.track_changes_rounded
                            : Icons.security_rounded,
                        color: color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item['title'] as String,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(item['time'] as String,
                        style:
                            const TextStyle(fontSize: 11, color: _textMuted)),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, color: _border, indent: 56),
            ],
          );
        }),
      ),
    );
  }

  // ─── Statistics View ────────────────────────────────────────────────────────

  Widget _buildStatisticsView(DashboardState state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHero(),
          const SizedBox(height: 32),
          _sectionLabel('WEEKLY THREATS BLOCKED'),
          const SizedBox(height: 14),
          _buildChartCard(),
          const SizedBox(height: 28),
          _sectionLabel('LIVE COUNTERS'),
          const SizedBox(height: 14),
          _buildLiveCounters(state),
          const SizedBox(height: 28),
          _sectionLabel('THREAT BREAKDOWN'),
          const SizedBox(height: 14),
          _buildThreatBreakdown(),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
      ),
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const SizedBox(
              height: 220,
              child: Center(
                  child: CircularProgressIndicator(
                      color: _emerald, strokeWidth: 2)),
            );
          }
          final stats = (state is DashboardLoaded)
              ? state.threatsOverTime
              : [12, 19, 8, 24, 16, 30, 22];
          final maxVal = stats.reduce((a, b) => a > b ? a : b).toDouble();

          return SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal + 8,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => _surfaceElevated,
                    tooltipBorder: const BorderSide(color: _border),
                    getTooltipItem: (group, gI, rod, rI) => BarTooltipItem(
                      '${rod.toY.toInt()}',
                      const TextStyle(
                          color: _emerald, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        if (v < 0 || v >= days.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            days[v.toInt()],
                            style: const TextStyle(
                                fontSize: 11,
                                color: _textMuted,
                                fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxVal / 3).ceilToDouble().clamp(1.0, double.infinity),
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: _border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(stats.length, (i) {
                  final isLast = i == stats.length - 1;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: stats[i].toDouble(),
                        gradient: LinearGradient(
                          colors: isLast
                              ? [_emerald, _emeraldDim]
                              : [
                                  _textMuted.withOpacity(0.3),
                                  _textMuted.withOpacity(0.1)
                                ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        width: 22,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveCounters(DashboardState state) {
    return Row(
      children: [
        _buildCounterCard(
            '${state is DashboardLoaded ? state.blockedDomainsCount : 0}',
            'Ads Blocked',
            Icons.block_rounded,
            _blue),
        const SizedBox(width: 12),
        _buildCounterCard(
            '${state is DashboardLoaded ? (state.threatTypes['Harmful Sites'] ?? 0) : 0}',
            'Harmful Sites',
            Icons.security_rounded,
            _coral),
      ],
    );
  }

  Widget _buildCounterCard(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: _textPrimary,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: _textSecondary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildThreatBreakdown() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const SizedBox(
                height: 100,
                child: Center(
                    child: CircularProgressIndicator(
                        color: _emerald, strokeWidth: 2)));
          }
          final threats = (state is DashboardLoaded)
              ? state.threatTypes
              : {
                  'Ads & Trackers': 72,
                  'Adult Content': 14,
                  'Gambling': 8,
                  'Malware': 6
                };

          final total = threats.values.fold<int>(0, (s, v) => s + v);
          final colors = [_blue, _coral, _amber, _emerald];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ...threats.entries.toList().asMap().entries.map((e) {
                  final idx = e.key;
                  final entry = e.value;
                  final pct = total > 0 ? entry.value / total : 0.0;
                  final color = colors[idx % colors.length];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      color: color, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 10),
                                Text(entry.key,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _textPrimary)),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '${(pct * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: color,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  entry.value.toString(),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: _textPrimary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: _surfaceElevated,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
