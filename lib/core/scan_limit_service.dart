import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';
import 'user_session.dart';

class ScanLimitService {
  static const int _max = 15;

  static String _countKey(String uid) => 'scan_count_$uid';
  static String _windowKey(String uid) => 'scan_window_start_$uid';


  static Future<ScanLimitStatus> getStatus() async {
    final uid = UserSession.userId;
    if (uid == null || uid.isEmpty) {
      return ScanLimitStatus(used: 0, max: _max, resetAt: null, isPremium: false);
    }

    // Try backend first (cross-device sync)
    try {
      final res = await http
          .get(Uri.parse(ApiConfig.scanLimit(uid)))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        final status = ScanLimitStatus(
          used: (d['used'] as num).toInt(),
          max: (d['max'] as num).toInt(),
          resetAt: d['resetAt'] != null ? DateTime.parse(d['resetAt']) : null,
          isPremium: false,
        );
        await _cacheStatus(uid, status); // keep local cache in sync
        return status;
      }
    } catch (e) {
      debugPrint('[ScanLimit] backend getStatus failed, using local cache: $e');
    }

    // Fallback: local SharedPreferences
    return _localStatus(uid);
  }

  /// Returns null if scan counted, resetAt if limit reached.
  static Future<DateTime?> checkAndIncrement() async {
    final uid = UserSession.userId;
    if (uid == null || uid.isEmpty) return null;

    // Try backend first
    try {
      final res = await http
          .post(Uri.parse(ApiConfig.scanLimitIncrement(uid)))
          .timeout(const Duration(seconds: 6));
      final d = jsonDecode(res.body);
      if (res.statusCode == 429) {
        return d['resetAt'] != null ? DateTime.parse(d['resetAt']) : null;
      }
      if (res.statusCode == 200) {
        final status = ScanLimitStatus(
          used: (d['used'] as num).toInt(),
          max: (d['max'] as num).toInt(),
          resetAt: d['resetAt'] != null ? DateTime.parse(d['resetAt']) : null,
          isPremium: false,
        );
        await _cacheStatus(uid, status);
        return null;
      }
    } catch (e) {
      debugPrint('[ScanLimit] backend increment failed, using local: $e');
    }

    // Fallback: local increment
    return _localIncrement(uid);
  }


  static Future<ScanLimitStatus> _localStatus(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final windowStr = prefs.getString(_windowKey(uid));
    final windowTime = windowStr != null ? DateTime.tryParse(windowStr) : null;

    if (windowTime == null || now.difference(windowTime).inHours >= 24) {
      return ScanLimitStatus(used: 0, max: _max, resetAt: null, isPremium: false);
    }

    final count = prefs.getInt(_countKey(uid)) ?? 0;
    return ScanLimitStatus(
      used: count,
      max: _max,
      resetAt: windowTime.add(const Duration(hours: 24)),
      isPremium: false,
    );
  }

  static Future<DateTime?> _localIncrement(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final countKey = _countKey(uid);
    final windowKey = _windowKey(uid);

    final windowStr = prefs.getString(windowKey);
    DateTime? windowTime = windowStr != null ? DateTime.tryParse(windowStr) : null;

    if (windowTime == null || now.difference(windowTime).inHours >= 24) {
      windowTime = now;
      await prefs.setString(windowKey, now.toIso8601String());
      await prefs.setInt(countKey, 0);
    }

    final count = prefs.getInt(countKey) ?? 0;
    if (count >= _max) return windowTime!.add(const Duration(hours: 24));

    await prefs.setInt(countKey, count + 1);
    return null;
  }

  static Future<void> _cacheStatus(String uid, ScanLimitStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey(uid), status.used);
    if (status.resetAt != null) {
      final windowStart = status.resetAt!.subtract(const Duration(hours: 24));
      await prefs.setString(_windowKey(uid), windowStart.toIso8601String());
    }
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
