import 'package:flutter/services.dart';

class AppBlockService {
  static const MethodChannel _channel =
      MethodChannel('com.walton.deenguard/appblock');

  static Future<bool> updateAppBlockingSettings({
    bool fbAppBlocked = false,
    bool fbReelsBlocked = false,
    bool ytAppBlocked = false,
    bool ytShortsBlocked = false,
    bool igAppBlocked = false,
    bool igReelsBlocked = false,
  }) async {
    try {
      print('[AppBlockService] updateAppBlockingSettings called: fbApp=$fbAppBlocked, fbReels=$fbReelsBlocked, ytApp=$ytAppBlocked, ytShorts=$ytShortsBlocked, igApp=$igAppBlocked, igReels=$igReelsBlocked');
      final bool? result = await _channel.invokeMethod('updateAppBlockingSettings', {
        'fb_app_blocked': fbAppBlocked,
        'fb_reels_blocked': fbReelsBlocked,
        'yt_app_blocked': ytAppBlocked,
        'yt_shorts_blocked': ytShortsBlocked,
        'ig_app_blocked': igAppBlocked,
        'ig_reels_blocked': igReelsBlocked,
      });
      print('[AppBlockService] Result: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      print("[AppBlockService] Failed to update app blocking settings: ${e.message}");
      return false;
    }
  }

  static Future<bool> checkAppBlockPermission() async {
    try {
      final bool? result = await _channel.invokeMethod('checkAppBlockPermission');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> openAppBlockSettings() async {
    try {
      await _channel.invokeMethod('openAppBlockSettings');
    } on PlatformException catch (e) {
      print("Failed to open app block settings: ${e.message}");
    }
  }

  static Future<void> openPrivateDnsSettings() async {
    try {
      await _channel.invokeMethod('openPrivateDnsSettings');
    } on PlatformException catch (e) {
      print("Failed to open private DNS settings: ${e.message}");
    }
  }
}
