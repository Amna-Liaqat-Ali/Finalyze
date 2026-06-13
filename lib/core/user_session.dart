class UserSession {
  static String? userId;
  static String? token;

  static void initialize({required String id, required String userToken}) {
    userId = id;
    token = userToken;
  }

  static void clear() {
    userId = null;
    token = null;
  }

  static bool get isLoggedIn => userId != null && userId!.isNotEmpty;
}
