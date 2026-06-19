import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class UserSession {
  static String? userId;
  static String? token;
  static String? name;
  static String? email;

  static const String _keyUserId = 'user_id';
  static const String _keyToken = 'user_token';
  static const String _keyName = 'user_name';
  static const String _keyEmail = 'user_email';

  static Future<void> initialize({
    required String id,
    required String userToken,
    String? userName,
    String? userEmail,
  }) async {
    userId = id;
    token = userToken;
    name = userName;
    email = userEmail;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, id);
    await prefs.setString(_keyToken, userToken);
    if (userName != null) await prefs.setString(_keyName, userName);
    if (userEmail != null) await prefs.setString(_keyEmail, userEmail);
  }

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(_keyUserId);
    token = prefs.getString(_keyToken);
    name = prefs.getString(_keyName);
    email = prefs.getString(_keyEmail);

    // If logged in but name not cached yet, fetch from backend
    if (isLoggedIn && (name == null || name!.isEmpty)) {
      await fetchProfile();
    }
  }

  static Future<void> fetchProfile() async {
    if (userId == null || userId!.isEmpty) return;
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.userProfile(userId!)),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        name = data['fullName']?.toString();
        email = data['email']?.toString();
        final prefs = await SharedPreferences.getInstance();
        if (name != null) await prefs.setString(_keyName, name!);
        if (email != null) await prefs.setString(_keyEmail, email!);
      }
    } catch (_) {}
  }

  static Future<void> clear() async {
    userId = null;
    token = null;
    name = null;
    email = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyToken);
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
  }

  static bool get isLoggedIn => userId != null && userId!.isNotEmpty;
}
