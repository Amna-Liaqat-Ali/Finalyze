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

  static Future<http.Response> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      return await http.post(
        Uri.parse(ApiConfig.register),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": name,
          "email": email,
          "password": password,
        }),
      );
    } catch (e) {
      rethrow;
    }
  }
}
