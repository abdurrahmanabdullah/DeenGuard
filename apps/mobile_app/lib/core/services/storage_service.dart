import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class StorageService {
  static late Box _box;
  static late Box _blockedDomainsBox;

  static Future<void> init() async {
    _box = await Hive.openBox(AppConstants.storageBoxName);
    _blockedDomainsBox = await Hive.openBox(AppConstants.blockedDomainsBox);
  }

  static Box get box => _box;
  static Box get blockedDomainsBox => _blockedDomainsBox;

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
    return List<String>.from(_blockedDomainsBox.get('domains', defaultValue: <String>[]));
  }

  static Future<void> clear() async {
    await _box.clear();
    await _blockedDomainsBox.clear();
  }
}
