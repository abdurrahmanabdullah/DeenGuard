import 'package:flutter/material.dart';

class SocialMediaControlsPage extends StatefulWidget {
  const SocialMediaControlsPage({super.key});

  @override
  State<SocialMediaControlsPage> createState() =>
      _SocialMediaControlsPageState();
}

class _SocialMediaControlsPageState extends State<SocialMediaControlsPage> {
  // Local state for toggles - in real app this would come from a Bloc/Storage
  final Map<String, bool> _settings = {
    'fb_reels': true,
    'fb_app': true,
    'yt_shorts': true,
    'yt_app': true,
    'ig_reels': true,
    'ig_app': false,
  };

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildPlatformSection(
              name: 'Facebook',
              icon: Icons.facebook,
              iconColor: Colors.blue[700]!,
              controls: [
                _buildControlRow(
                  label: 'Block Reels',
                  icon: Icons.play_circle_outline,
                  value: _settings['fb_reels']!,
                  onChanged: (v) => setState(() => _settings['fb_reels'] = v),
                ),
                _buildControlRow(
                  label: 'Block Facebook',
                  icon: Icons.block_flipped,
                  value: _settings['fb_app']!,
                  onChanged: (v) => setState(() => _settings['fb_app'] = v),
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
                  value: _settings['yt_shorts']!,
                  onChanged: (v) => setState(() => _settings['yt_shorts'] = v),
                ),
                _buildControlRow(
                  label: 'Block Youtube',
                  icon: Icons.block_flipped,
                  value: _settings['yt_app']!,
                  onChanged: (v) => setState(() => _settings['yt_app'] = v),
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
                  value: _settings['ig_reels']!,
                  onChanged: (v) => setState(() => _settings['ig_reels'] = v),
                ),
                _buildControlRow(
                  label: 'Block Instagram',
                  icon: Icons.block_flipped,
                  value: _settings['ig_app']!,
                  onChanged: (v) => setState(() => _settings['ig_app'] = v),
                  isLast: true,
                ),
              ],
            ),
          ],
        ),
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
