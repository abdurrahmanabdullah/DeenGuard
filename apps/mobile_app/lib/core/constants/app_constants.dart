import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4C8C4A);
  static const Color primaryDark = Color(0xFF003300);

  static const Color secondary = Color(0xFF00897B);
  static const Color secondaryLight = Color(0xFF4EBAAA);
  static const Color secondaryDark = Color(0xFF005B4F);

  static const Color accent = Color(0xFFFF9800);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);

  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
}

class AppConstants {
  static const String appName = 'DeenGuard';
  static const String appVersion = '1.0.0';

  static const String apiBaseUrl = 'http://localhost:3000';
  static const String wsBaseUrl = 'ws://localhost:3000';

  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheExpiry = Duration(hours: 24);

  static const int maxBlockedDomains = 100000;
  static const int syncIntervalMinutes = 30;

  static const String storageBoxName = 'deenguard_box';
  static const String blockedDomainsBox = 'blocked_domains';
  static const String userPrefsBox = 'user_prefs';
  static const String statsBox = 'stats_box';
  static const String activityBox = 'activity_box';
}
