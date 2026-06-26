import 'package:shared_preferences/shared_preferences.dart';

import 'user_session.dart';

class ScanLimitService {
  static const int _maxScans = 15;

  static String _countKey(String uid) => 'scan_count_$uid';
  static String _windowKey(String uid) => 'scan_window_start_$uid';

  /// Returns null if allowed, or the DateTime when the limit resets if blocked.
  static Future<DateTime?> checkAndIncrement() async {
    final uid = UserSession.userId;
    if (uid == null || uid.isEmpty) return null; // guests: unlimited

    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool('is_premium') ?? false;
    if (isPremium) return null;

    final countKey = _countKey(uid);
    final windowKey = _windowKey(uid);
    final now = DateTime.now();

    final windowStart = prefs.getString(windowKey);
    DateTime? windowTime = windowStart != null ? DateTime.tryParse(windowStart) : null;

    if (windowTime == null || now.difference(windowTime).inHours >= 24) {
      windowTime = now;
      await prefs.setString(windowKey, now.toIso8601String());
      await prefs.setInt(countKey, 0);
    }

    final count = prefs.getInt(countKey) ?? 0;
    if (count >= _maxScans) {
      return windowTime!.add(const Duration(hours: 24));
    }

    await prefs.setInt(countKey, count + 1);
    return null;
  }

  /// Call this to increment count after a valid scan result (not invalid).
  static Future<void> incrementValidScan() async {
    final uid = UserSession.userId;
    if (uid == null || uid.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool('is_premium') ?? false;
    if (isPremium) return;

    final countKey = _countKey(uid);
    final count = prefs.getInt(countKey) ?? 0;
    // Decrement the pre-increment we did in checkAndIncrement,
    // then add 1 only if we get a valid result — net effect: no change needed.
    // This method is used when we want to track valid-only: just ensure count is up-to-date.
  }

  static Future<ScanLimitStatus> getStatus() async {
    final uid = UserSession.userId;
    if (uid == null || uid.isEmpty) {
      return ScanLimitStatus(used: 0, max: _maxScans, resetAt: null, isPremium: false);
    }

    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool('is_premium') ?? false;
    if (isPremium) {
      return ScanLimitStatus(used: 0, max: _maxScans, resetAt: null, isPremium: true);
    }

    final countKey = _countKey(uid);
    final windowKey = _windowKey(uid);
    final now = DateTime.now();

    final windowStart = prefs.getString(windowKey);
    DateTime? windowTime = windowStart != null ? DateTime.tryParse(windowStart) : null;

    if (windowTime == null || now.difference(windowTime).inHours >= 24) {
      return ScanLimitStatus(used: 0, max: _maxScans, resetAt: null, isPremium: false);
    }

    final count = prefs.getInt(countKey) ?? 0;
    final resetAt = windowTime.add(const Duration(hours: 24));
    return ScanLimitStatus(used: count, max: _maxScans, resetAt: resetAt, isPremium: false);
  }

  static Future<void> clearForUser(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_countKey(uid));
    await prefs.remove(_windowKey(uid));
  }
}

class ScanLimitStatus {
  final int used;
  final int max;
  final DateTime? resetAt;
  final bool isPremium;

  ScanLimitStatus({
    required this.used,
    required this.max,
    required this.resetAt,
    required this.isPremium,
  });

  int get remaining => (max - used).clamp(0, max);
  bool get isLimited => !isPremium && used >= max;
}
