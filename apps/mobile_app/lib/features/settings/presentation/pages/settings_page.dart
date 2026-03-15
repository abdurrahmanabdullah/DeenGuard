import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/services/app_block_service.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
const _bg = Color(0xFF0D1117);
const _surface = Color(0xFF161B22);
const _surfaceElevated = Color(0xFF1C232B);
const _emerald = Color(0xFF00E676);
const _textPrimary = Color(0xFFE6EDF3);
const _textSecondary = Color(0xFF8B949E);
const _textMuted = Color(0xFF484F58);
const _border = Color(0xFF21262D);
const _blue = Color(0xFF58A6FF);
const _coral = Color(0xFFFF7B72);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic> _usageStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsageStats();
  }

  Future<void> _loadUsageStats() async {
    final stats = await AppBlockService.getUsageStats();
    if (mounted) {
      setState(() {
        _usageStats = stats;
        _isLoading = false;
      });
    }
  }

  Future<void> _sendReport() async {
    const String backendUrl = 'http://192.168.2.247:5000/api/reports/send'; // Updated to your real IP for physical phone
    print('[DEBUG] Attempting to send report to: $backendUrl');
    
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_usageStats),
      ).timeout(const Duration(seconds: 10));

      print('[DEBUG] Response status: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      if (mounted) {
        if (response.statusCode == 201 || response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report sent successfully!'),
              backgroundColor: _emerald,
            ),
          );
        } else {
          throw Exception('Backend returned ${response.statusCode}: ${response.body}');
        }
      }
    } catch (e) {
      print('[ERROR] Failed to send report: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending report: $e'),
            backgroundColor: _coral,
            duration: const Duration(seconds: 10),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDuration(int ms) {
    if (ms <= 0) return "0m";
    final Duration duration = Duration(milliseconds: ms);
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return "${hours}h ${minutes}m";
    }
    return "${minutes}m";
  }

  @override
  Widget build(BuildContext context) {
    final int totalMs = _usageStats['total_ms'] ?? 0;
    // Calculate % of day on phone (assuming 24h as total day, but typically people look at active hours)
    // Here we'll just show the total time as requested in the screenshot.
    
    return Container(
      color: _bg,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainHeader(totalMs),
            const SizedBox(height: 40),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: _emerald))
            else ...[
              _buildAppUsageSection('facebook', 'Facebook', Icons.facebook_rounded, const Color(0xFF1877F2), _coral, totalMs),
              const SizedBox(height: 32),
              _buildAppUsageSection('youtube', 'YouTube', Icons.play_circle_fill_rounded, const Color(0xFFFF0000), _blue, totalMs),
              const SizedBox(height: 32),
              _buildAppUsageSection('instagram', 'Instagram', Icons.camera_alt_rounded, const Color(0xFFE4405F), _emerald, totalMs),
              const SizedBox(height: 32),
              _buildAppUsageSection('whatsapp', 'WhatsApp', Icons.chat_bubble_rounded, const Color(0xFF25D366), _emerald, totalMs),
            ],
            const SizedBox(height: 60),
            _buildFooterInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainHeader(int totalMs) {
    // 24 hours in ms = 24 * 60 * 60 * 1000 = 86,400,000
    final double dayPercent = totalMs > 0 ? (totalMs / 86400000) * 100 : 0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's",
              style: TextStyle(
                color: _textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDuration(totalMs),
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _sendReport,
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text("Send Report"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _emerald.withOpacity(0.1),
                foregroundColor: _emerald,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: _emerald, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "% of Day on Phone",
              style: TextStyle(
                color: _textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${dayPercent.toStringAsFixed(0)}%",
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppUsageSection(String key, String label, IconData icon, Color iconColor, Color barColor, int totalMs) {
    final Map<dynamic, dynamic>? appData = _usageStats[key];
    final int appMs = appData?['ms'] ?? 0;
    final double percentOfTotal = totalMs > 0 ? (appMs / totalMs) * 100 : 0;
    
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              _formatDuration(appMs),
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "${percentOfTotal.toStringAsFixed(1)}%",
              style: const TextStyle(
                color: _textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSegmentedProgressBar(percentOfTotal / 100, barColor),
      ],
    );
  }

  Widget _buildSegmentedProgressBar(double progress, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const int totalSegments = 20;
        final int activeSegments = (progress * totalSegments).round();
        
        return Row(
          children: List.generate(totalSegments, (index) {
            final bool isActive = index < activeSegments;
            return Expanded(
              child: Container(
                height: 14,
                margin: EdgeInsets.only(right: index == totalSegments - 1 ? 0 : 2),
                decoration: BoxDecoration(
                  color: isActive ? color : _textMuted.withOpacity(0.15),
                  borderRadius: BorderRadius.horizontal(
                    left: index == 0 ? const Radius.circular(4) : Radius.zero,
                    right: index == totalSegments - 1 ? const Radius.circular(4) : Radius.zero,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildFooterInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceElevated.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: _textMuted, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Usage stats are updated in real-time as you switch between applications.',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
