class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  static String get login => '$baseUrl/auth/signin';
  static String get register => '$baseUrl/auth/signup';
}
