import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocking/bloc/blocking_bloc.dart';
import '../../../../core/services/app_block_service.dart';

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
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Social Media'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<BlockingBloc, BlockingState>(
        builder: (context, state) {
          final settings = state is BlockingStatusLoaded
              ? state.socialMediaSettings
              : <String, bool>{};
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                if (_checkingPermission)
                  const LinearProgressIndicator()
                else if (!_hasPermission)
                  _buildPermissionWarning(),
                if (!_hasPermission) const SizedBox(height: 16),
                const SizedBox(height: 8),
                _buildPlatformSection(
                  name: 'Facebook',
                  icon: Icons.facebook,
                  iconColor: Colors.blue[700]!,
                  controls: [
                    _buildControlRow(
                      label: 'Block Reels',
                      icon: Icons.play_circle_outline,
                      value: settings['fb_reels'] ?? false,
                      onChanged: (v) {
                        print('[DEBUG UI] fb_reels toggled to: $v');
                        context
                            .read<BlockingBloc>()
                            .add(UpdateSocialMediaSetting(key: 'fb_reels', value: v));
                      },
                    ),
                    _buildControlRow(
                      label: 'Block Facebook',
                      icon: Icons.block_flipped,
                      value: settings['fb_app'] ?? false,
                      onChanged: (v) {
                        print('[DEBUG UI] fb_app toggled to: $v');
                        context
                            .read<BlockingBloc>()
                            .add(UpdateSocialMediaSetting(key: 'fb_app', value: v));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPlatformSection(
                  name: 'YouTube',
                  icon: Icons.play_arrow_rounded,
                  iconColor: Colors.red[600]!,
                  controls: [
                    _buildControlRow(
                      label: 'Block Shorts',
                      icon: Icons.play_arrow_outlined,
                      value: settings['yt_shorts'] ?? false,
                      onChanged: (v) => context
                          .read<BlockingBloc>()
                          .add(UpdateSocialMediaSetting(key: 'yt_shorts', value: v)),
                    ),
                    _buildControlRow(
                      label: 'Block Youtube',
                      icon: Icons.block_flipped,
                      value: settings['yt_app'] ?? false,
                      onChanged: (v) => context
                          .read<BlockingBloc>()
                          .add(UpdateSocialMediaSetting(key: 'yt_app', value: v)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPlatformSection(
                  name: 'Instagram',
                  icon: Icons.camera_alt_outlined,
                  iconColor: Colors.pink[400]!,
                  controls: [
                    _buildControlRow(
                      label: 'Block Reels',
                      icon: Icons.video_collection_outlined,
                      value: settings['ig_reels'] ?? false,
                      onChanged: (v) => context
                          .read<BlockingBloc>()
                          .add(UpdateSocialMediaSetting(key: 'ig_reels', value: v)),
                    ),
                    _buildControlRow(
                      label: 'Block Instagram',
                      icon: Icons.block_flipped,
                      value: settings['ig_app'] ?? false,
                      onChanged: (v) => context
                          .read<BlockingBloc>()
                          .add(UpdateSocialMediaSetting(key: 'ig_app', value: v)),
                      isLast: true,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.share_outlined, color: Colors.blue[700], size: 28),
        ),
        const SizedBox(width: 16),
        const Text(
          'Social Media Controls',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3250),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Enable to block on Mobile Data',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'To block on mobile data (not just WiFi), enable the App Block permission.',
            style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await AppBlockService.openAppBlockSettings();
                    await Future.delayed(const Duration(seconds: 2));
                    _checkPermissions();
                  },
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('Enable Permission'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'For browser blocking on mobile data, go to Settings > Network > Private DNS and enter: dns.adguard-dns.com',
            style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3250),
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_up, color: Colors.grey[400]),
              ],
            ),
          ),
          const Divider(height: 1),
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
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[50]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.red[400], size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424769),
              ),
            ),
          ),
          Icon(Icons.info_outline, color: Colors.blueGrey[200], size: 18),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.red[400],
            activeTrackColor: Colors.red[100],
          ),
        ],
      ),
    );
  }
}
