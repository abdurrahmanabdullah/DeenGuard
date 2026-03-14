import 'package:flutter/services.dart';

class VpnService {
  static const MethodChannel _channel =
      MethodChannel('com.walton.deenguard/vpn');

  static Future<bool> startVpn() async {
    try {
      final bool? result = await _channel.invokeMethod('startVpn');
      return result ?? false;
    } on PlatformException catch (e) {
      print("Failed to start VPN: '\${e.message}'.");
      return false;
    }
  }

  static Future<void> stopVpn() async {
    try {
      await _channel.invokeMethod('stopVpn');
    } on PlatformException catch (e) {
      print("Failed to stop VPN: '\${e.message}'.");
    }
  }

  static Future<bool> checkVpnStatus() async {
    try {
      final bool? result = await _channel.invokeMethod('checkVpnStatus');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> restartVpn() async {
    try {
      final bool? result = await _channel.invokeMethod('restartVpn');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
