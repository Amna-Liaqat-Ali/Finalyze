import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/api_config.dart';

class AuthService {
  static Future<http.Response> login(String email, String password) async {
    try {
      return await http.post(
        Uri.parse(ApiConfig.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
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
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": name,
          "email": email,
          "password": password,
          "userRole": userRole,
          "region": region,
        }),
      );
    } catch (e) {
      rethrow;
    }
  }
}
