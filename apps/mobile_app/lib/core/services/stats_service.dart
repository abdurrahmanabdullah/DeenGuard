import 'storage_service.dart';

class StatsService {
  static const String keyTotalAds = 'total_ads_blocked';
  static const String keyTotalHarmful = 'total_harmful_blocked';
  static const String keyWeeklyStats = 'weekly_stats';
  static const String keyActivityFeed = 'activity_feed';

  static int getTotalAdsBlocked() {
    return StorageService.statsBox.get(keyTotalAds, defaultValue: 0);
  }

  static int getTotalHarmfulBlocked() {
    return StorageService.statsBox.get(keyTotalHarmful, defaultValue: 0);
  }

  static List<int> getWeeklyStats() {
    final stats = StorageService.statsBox.get(keyWeeklyStats);
    if (stats == null) return [0, 0, 0, 0, 0, 0, 0];
    return List<int>.from(stats);
  }

  static List<Map<String, dynamic>> getActivityFeed() {
    final feed = StorageService.activityBox.get(keyActivityFeed);
    if (feed == null) return [];
    return List<Map<String, dynamic>>.from(feed.map((e) => Map<String, dynamic>.from(e)));
  }

  static Future<void> recordBlock({
    required String title,
    required String type, // 'ads' or 'harmful'
    required String iconPath,
  }) async {
    // 1. Update totals
    if (type == 'ads') {
      final current = getTotalAdsBlocked();
      await StorageService.statsBox.put(keyTotalAds, current + 1);
    } else {
      final current = getTotalHarmfulBlocked();
      await StorageService.statsBox.put(keyTotalHarmful, current + 1);
    }

    // 2. Update weekly stats (current day)
    final weekly = getWeeklyStats();
    final todayIndex = DateTime.now().weekday - 1; // 0 is Monday
    weekly[todayIndex]++;
    await StorageService.statsBox.put(keyWeeklyStats, weekly);

    // 3. Update activity feed
    final feed = getActivityFeed();
    feed.insert(0, {
      'title': title,
      'time': _formatCurrentTime(),
      'type': type,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    // Keep only last 20 entries
    if (feed.length > 20) feed.removeLast();
    await StorageService.activityBox.put(keyActivityFeed, feed);
  }

  static String _formatCurrentTime() {
    return "Just now"; // For simplicity, we can enhance this later
  }

  static Map<String, int> getThreatBreakdown() {
    final ads = getTotalAdsBlocked();
    final harmful = getTotalHarmfulBlocked();
    // Default categories for breakdown
    return {
      'Ads & Trackers': ads,
      'Harmful Sites': harmful,
      'Adult Content': (harmful * 0.7).toInt(), // Mock breakdown of harmful
      'Gambling': (harmful * 0.3).toInt(),     // Mock breakdown of harmful
    };
  }
}
