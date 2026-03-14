import 'package:flutter/material.dart';
import 'social_media_controls_page.dart';

class FocusModePage extends StatelessWidget {
  const FocusModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Focus Mode'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoBanner(),
            const SizedBox(height: 24),
            _buildFocusOption(
              context,
              title: 'Social Media',
              subtitle: 'Block content within social platforms',
              icon: Icons.share_outlined,
              iconColor: Colors.teal[600]!,
              backgroundColor: Colors.teal[50]!,
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
              subtitle: 'Block individual apps or category groups',
              icon: Icons.grid_view_rounded,
              iconColor: Colors.orange[600]!,
              backgroundColor: Colors.orange[50]!,
              onTap: () {},
            ),
            _buildFocusOption(
              context,
              title: 'Website Blocker',
              subtitle: 'Block websites in browsers',
              icon: Icons.language_outlined,
              iconColor: Colors.deepPurple[400]!,
              backgroundColor: Colors.deepPurple[50]!,
              onTap: () {},
            ),
            _buildFocusOption(
              context,
              title: 'Harm Blocker',
              subtitle: 'Block harmful content like adult, drug, and gambling keywords',
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.red[400]!,
              backgroundColor: Colors.red[50]!,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lightbulb_outline, color: Colors.orange[700]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Protection Getting Stopped?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap here to see how to keep your protection running',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.auto_awesome, color: Colors.orange[200], size: 20),
        ],
      ),
    );
  }

  Widget _buildFocusOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 0,
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blueGrey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: iconColor.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
