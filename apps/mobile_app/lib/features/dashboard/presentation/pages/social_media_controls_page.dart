import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocking/bloc/blocking_bloc.dart';
import '../../../../core/services/app_block_service.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
const _bg = Color(0xFF0D1117);
const _surface = Color(0xFF161B22);
const _surfaceElevated = Color(0xFF1C232B);
const _emerald = Color(0xFF00E676);
const _textPrimary = Color(0xFFE6EDF3);
const _textSecondary = Color(0xFF8B949E);
const _textMuted = Color(0xFF484F58);
const _amber = Color(0xFFFFB300);
const _border = Color(0xFF21262D);
const _blue = Color(0xFF58A6FF);

class SocialMediaControlsPage extends StatefulWidget {
  const SocialMediaControlsPage({super.key});

  @override
  State<SocialMediaControlsPage> createState() =>
      _SocialMediaControlsPageState();
}

class _SocialMediaControlsPageState extends State<SocialMediaControlsPage> {
  bool _hasPermission = false;
  bool _checkingPermission = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlockingBloc>().add(LoadSocialMediaSettings());
      _checkPermissions();
    });
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await AppBlockService.checkAppBlockPermission();
    if (mounted) {
      setState(() {
        _hasPermission = hasPermission;
        _checkingPermission = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: BlocBuilder<BlockingBloc, BlockingState>(
        builder: (context, state) {
          final settings = state is BlockingStatusLoaded
              ? state.socialMediaSettings
              : <String, bool>{};

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 180.0,
                floating: false,
                pinned: true,
                stretch: true,
                backgroundColor: _bg,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textSecondary, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: const Text(
                    'Social Media',
                    style: TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.5,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_bg, _surface],
                          ),
                        ),
                      ),
                      Positioned(
                        right: -40,
                        bottom: -40,
                        child: Icon(
                          Icons.share_rounded,
                          size: 160,
                          color: _blue.withOpacity(0.03),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('STATUS & PERMISSION'),
                      const SizedBox(height: 16),
                      if (_checkingPermission)
                        const LinearProgressIndicator(
                          backgroundColor: _surface,
                          valueColor: AlwaysStoppedAnimation<Color>(_blue),
                        )
                      else if (!_hasPermission)
                        _buildPermissionWarning()
                      else
                        _buildActiveStatusBanner(),
                      const SizedBox(height: 24),
                      _buildSectionHeader('PLATFORM CONTROLS'),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildPlatformSection(
                      name: 'Facebook',
                      icon: Icons.facebook_rounded,
                      iconColor: const Color(0xFF1877F2),
                      controls: [
                        _buildControlRow(
                          label: 'Block Reels',
                          icon: Icons.play_circle_outline,
                          value: settings['fb_reels'] ?? false,
                          onChanged: (v) => context.read<BlockingBloc>().add(UpdateSocialMediaSetting(key: 'fb_reels', value: v)),
                        ),
                        _buildControlRow(
                          label: 'Block App',
                          icon: Icons.block_flipped,
                          value: settings['fb_app'] ?? false,
                          onChanged: (v) => context.read<BlockingBloc>().add(UpdateSocialMediaSetting(key: 'fb_app', value: v)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPlatformSection(
                      name: 'YouTube',
                      icon: Icons.play_circle_fill_rounded,
                      iconColor: const Color(0xFFFF0000),
                      controls: [
                        _buildControlRow(
                          label: 'Block Shorts',
                          icon: Icons.bolt_rounded,
                          value: settings['yt_shorts'] ?? false,
                          onChanged: (v) => context.read<BlockingBloc>().add(UpdateSocialMediaSetting(key: 'yt_shorts', value: v)),
                        ),
                        _buildControlRow(
                          label: 'Block App',
                          icon: Icons.block_flipped,
                          value: settings['yt_app'] ?? false,
                          onChanged: (v) => context.read<BlockingBloc>().add(UpdateSocialMediaSetting(key: 'yt_app', value: v)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPlatformSection(
                      name: 'Instagram',
                      icon: Icons.camera_alt_rounded,
                      iconColor: const Color(0xFFE4405F),
                      controls: [
                        _buildControlRow(
                          label: 'Block Reels',
                          icon: Icons.video_collection_outlined,
                          value: settings['ig_reels'] ?? false,
                          onChanged: (v) => context.read<BlockingBloc>().add(UpdateSocialMediaSetting(key: 'ig_reels', value: v)),
                        ),
                        _buildControlRow(
                          label: 'Block App',
                          icon: Icons.block_flipped,
                          value: settings['ig_app'] ?? false,
                          onChanged: (v) => context.read<BlockingBloc>().add(UpdateSocialMediaSetting(key: 'ig_app', value: v)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _textMuted,
        letterSpacing: 1.6,
      ),
    );
  }

  Widget _buildActiveStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _emerald.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _emerald.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: _emerald, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Protection is active',
            style: TextStyle(fontWeight: FontWeight.w800, color: _emerald, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionWarning() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _amber.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: _amber),
              const SizedBox(width: 8),
              const Text(
                'Action Required',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: _textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Enable App Block permission to restrict apps on mobile data.',
            style: TextStyle(color: _textSecondary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await AppBlockService.openAppBlockSettings();
                await Future.delayed(const Duration(seconds: 2));
                _checkPermissions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _amber,
                foregroundColor: _bg,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Enable Now',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformSection({
    required String name,
    required IconData icon,
    required Color iconColor,
    required List<Widget> controls,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down_rounded, color: _textMuted),
              ],
            ),
          ),
          const Divider(height: 1, color: _border, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: controls),
          ),
        ],
      ),
    );
  }

  Widget _buildControlRow({
    required String label,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _surfaceElevated.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _textMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _textSecondary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _emerald,
            activeTrackColor: _emerald.withOpacity(0.1),
            inactiveThumbColor: _textMuted,
            inactiveTrackColor: _textMuted.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}
