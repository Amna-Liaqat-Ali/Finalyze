import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/api_config.dart';

class AuthService {
  static Future<http.Response> login(String email, String password) async {
    try {
      return await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> register({
    required String name,
    required String email,
    required String password,
    required String userRole,
    required String region,
    required String organization,
  }) async {
    try {
      return await http.post(
        Uri.parse(ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': name,
          'email': email,
          'password': password,
          'userRole': userRole,
          'region': region,
          'organization': organization,
        }),
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return http.post(
      Uri.parse(ApiConfig.verifyOtp),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
  }

  static Future<http.Response> resendOtp({required String email}) async {
    return http.post(
      Uri.parse(ApiConfig.resendOtp),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
  }

  static Future<http.Response> forgotPassword({required String email}) async {
    return http.post(
      Uri.parse(ApiConfig.forgotPassword),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
  }

  static Future<http.Response> deleteAccount(String userId) async {
    return http.delete(
      Uri.parse(ApiConfig.deleteAccount(userId)),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Future<http.Response> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    return http.post(
      Uri.parse(ApiConfig.resetPassword),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      }),
    );
  }
}
