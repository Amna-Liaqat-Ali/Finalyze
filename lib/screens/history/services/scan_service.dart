import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../core/api_config.dart';
import '../../../core/user_session.dart';

class ScanService {
  static Future<http.Response> saveScanResult({
    required String userId,
    required File imageFile,
    required String fishName,
    required String category,
    required double percentage,
    required String area,
    required String date,
    required String time,
  }) async {
    final imageBytes = await imageFile.readAsBytes();
    final imageData = await compute(base64Encode, imageBytes);

    return http.post(
      Uri.parse(ApiConfig.saveScan),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'fishName': fishName,
        'category': category,
        'percentage': percentage,
        'area': area,
        'scanDate': date,
        'scanTime': time,
        'imageData': imageData,
      }),
    );
  }

  static Future<bool> saveScanFromAnalysis({
    required File imageFile,
    required String detectedLabel,
    required double confidence,
    required String scanArea,
  }) async {
    if (!UserSession.isLoggedIn) return false;

    final normalizedLabel = detectedLabel.toLowerCase();
    if (normalizedLabel == 'data_invalid' || normalizedLabel == 'invalid_data') {
      return false;
    }

    final parts = detectedLabel.split('_');
    final speciesKey = parts.isNotEmpty ? parts[0].toLowerCase() : 'unknown';
    final status = parts.length > 1 ? parts[1].toUpperCase() : 'UNKNOWN';

    const speciesNames = {
      'pomfret': 'Pomfret (Paplet)',
      'surmai': 'Kingfish (Surmai)',
    };
    final species = speciesNames[speciesKey] ?? speciesKey.toUpperCase();

    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final formattedTime = DateFormat('hh:mm:ss a').format(now);

    try {
      if (!await imageFile.exists()) {
        debugPrint('[ScanService] Image file missing: ${imageFile.path}');
        return false;
      }

      final response = await saveScanResult(
        userId: UserSession.userId!,
        imageFile: imageFile,
        fishName: species,
        category: status,
        percentage: confidence * 100,
        area: scanArea,
        date: formattedDate,
        time: formattedTime,
      );

      debugPrint(
        '[ScanService] Save response ${response.statusCode}: ${response.body}',
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('[ScanService] Save failed: $e');
      return false;
    }
  }

  static Future<bool> deleteScan(String scanId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/scan/$scanId');
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('[ScanService] Delete failed: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getUserScanHistory(String userId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/scan/history/$userId');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed loading history logs from server pipeline backend.',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<String?> getScanImage(String scanId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.scanDetail(scanId)),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['imageData'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
