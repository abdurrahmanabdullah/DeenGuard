import 'package:flutter/material.dart';
import 'social_media_controls_page.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
const _bg = Color(0xFF0D1117);
const _surface = Color(0xFF161B22);
const _surfaceElevated = Color(0xFF1C232B);
const _emerald = Color(0xFF00E676);
const _emeraldGlow = Color(0x2200E676);
const _textPrimary = Color(0xFFE6EDF3);
const _textSecondary = Color(0xFF8B949E);
const _textMuted = Color(0xFF484F58);
const _amber = Color(0xFFFFB300);
const _coral = Color(0xFFFF5370);
const _blue = Color(0xFF58A6FF);
const _border = Color(0xFF21262D);

class FocusModePage extends StatelessWidget {
  const FocusModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
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
                'Focus Mode',
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
                    right: -50,
                    top: -20,
                    child: Icon(
                      Icons.center_focus_strong,
                      size: 200,
                      color: _emerald.withOpacity(0.03),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _emeraldGlow,
                          shape: BoxShape.circle,
                          border: Border.all(color: _emerald.withOpacity(0.1)),
                        ),
                        child: const Icon(
                          Icons.visibility_off_rounded,
                          size: 48,
                          color: _emerald,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('CONTROL YOUR FOCUS'),
                  const SizedBox(height: 16),
                  _buildInfoBanner(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('BLOCKING OPTIONS'),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildFocusOption(
                  context,
                  title: 'Social Media',
                  description: 'Manage app-level and internal platform blocks',
                  icon: Icons.share_rounded,
                  accentColor: _blue,
                  gradient: [const Color(0xFF0D47A1), const Color(0xFF001970)],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SocialMediaControlsPage()),
                    );
                  },
                ),
                _buildFocusOption(
                  context,
                  title: 'App Blocker',
                  description: 'Select individual apps to completely disable',
                  icon: Icons.grid_view_rounded,
                  accentColor: _amber,
                  gradient: [const Color(0xFF4E342E), const Color(0xFF2E1B1B)],
                  onTap: () {},
                ),
                _buildFocusOption(
                  context,
                  title: 'Website Blocker',
                  description: 'Filter distractions while you browse',
                  icon: Icons.language_rounded,
                  accentColor: const Color(0xFF7C4DFF),
                  gradient: [const Color(0xFF311B92), const Color(0xFF12005E)],
                  onTap: () {},
                ),
                _buildFocusOption(
                  context,
                  title: 'Harm Blocker',
                  description: 'Automatic filtering of harmful keywords',
                  icon: Icons.security_rounded,
                  accentColor: _coral,
                  gradient: [const Color(0xFF4A0000), const Color(0xFF2A0000)],
                  onTap: () {},
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
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

  Widget _buildInfoBanner() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _amber.withOpacity(0.2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.tips_and_updates_rounded, color: _amber, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stay Protected',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Setup battery optimization to keep DeenGuard active.',
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: _textMuted, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFocusOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: accentColor.withOpacity(0.2)),
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: _border),
                  ),
                  child: const Icon(Icons.chevron_right_rounded, color: _textMuted, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
