import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static String? userId;
  static String? token;

  static const String _keyUserId = 'user_id';
  static const String _keyToken = 'user_token';

  // save to local disk automatically
  static Future<void> initialize({
    required String id,
    required String userToken,
  }) async {
    userId = id;
    token = userToken;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, id);
    await prefs.setString(_keyToken, userToken);
  }

  // on app startup reads from storage to memory
  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(_keyUserId);
    token = prefs.getString(_keyToken);
  }

  // clear both storage and memory on logout
  static Future<void> clear() async {
    userId = null;
    token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyToken);
  }

  static bool get isLoggedIn => userId != null && userId!.isNotEmpty;
}
