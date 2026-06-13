class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  static String get login => '$baseUrl/auth/signin';
  static String get register => '$baseUrl/auth/signup';
  static String get verifyOtp => '$baseUrl/auth/verify-otp';
  static String get resendOtp => '$baseUrl/auth/resend-otp';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';
  static String get resetPassword => '$baseUrl/auth/reset-password';
  static String get saveScan => '$baseUrl/scan/save-scan';
}
