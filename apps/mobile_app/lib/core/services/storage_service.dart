import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class StorageService {
  static late Box _box;
  static late Box _blockedDomainsBox;
  static late Box _statsBox;
  static late Box _activityBox;

  static Future<void> init() async {
    _box = await Hive.openBox(AppConstants.storageBoxName);
    _blockedDomainsBox = await Hive.openBox(AppConstants.blockedDomainsBox);
    _statsBox = await Hive.openBox(AppConstants.statsBox);
    _activityBox = await Hive.openBox(AppConstants.activityBox);
  }

  static Box get box => _box;
  static Box get blockedDomainsBox => _blockedDomainsBox;
  static Box get statsBox => _statsBox;
  static Box get activityBox => _activityBox;

  static Future<void> setString(String key, String value) async {
    await _box.put(key, value);
  }

  static String? getString(String key) {
    return _box.get(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _box.put(key, value);
  }

  static bool? getBool(String key) {
    return _box.get(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _box.put(key, value);
  }

  static int? getInt(String key) {
    return _box.get(key);
  }

  static Future<void> setBlockedDomains(List<String> domains) async {
    await _blockedDomainsBox.put('domains', domains);
  }

  static List<String> getBlockedDomains() {
    return List<String>.from(
        _blockedDomainsBox.get('domains', defaultValue: <String>[]));
  }

  static Future<void> clear() async {
    await _box.clear();
    await _blockedDomainsBox.clear();
  }

  static const String keyFbApp = 'fb_app_blocked';
  static const String keyFbReels = 'fb_reels_blocked';
  static const String keyYtApp = 'yt_app_blocked';
  static const String keyYtShorts = 'yt_shorts_blocked';
  static const String keyIgApp = 'ig_app_blocked';
  static const String keyIgReels = 'ig_reels_blocked';

  static Future<void> setSocialMediaSettings(Map<String, bool> settings) async {
    print('[Storage] Saving settings: $settings');
    await _box.put(keyFbApp, settings['fb_app'] ?? false);
    await _box.put(keyFbReels, settings['fb_reels'] ?? false);
    await _box.put(keyYtApp, settings['yt_app'] ?? false);
    await _box.put(keyYtShorts, settings['yt_shorts'] ?? false);
    await _box.put(keyIgApp, settings['ig_app'] ?? false);
    await _box.put(keyIgReels, settings['ig_reels'] ?? false);
    print('[Storage] Settings saved successfully');
  }

  static Map<String, bool> getSocialMediaSettings() {
    final result = {
      'fb_app': _box.get(keyFbApp, defaultValue: false) as bool,
      'fb_reels': _box.get(keyFbReels, defaultValue: false) as bool,
      'yt_app': _box.get(keyYtApp, defaultValue: false) as bool,
      'yt_shorts': _box.get(keyYtShorts, defaultValue: false) as bool,
      'ig_app': _box.get(keyIgApp, defaultValue: false) as bool,
      'ig_reels': _box.get(keyIgReels, defaultValue: false) as bool,
    };
    print('[Storage] getSocialMediaSettings returned: $result');
    return result;
  }
}
