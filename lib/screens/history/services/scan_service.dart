import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../../../core/api_config.dart';
import '../../../core/user_session.dart';

class ScanService {
  static Future<http.StreamedResponse> saveScanResult({
    required String userId,
    required File imageFile,
    required String fishName,
    required String category,
    required double percentage,
    required String area,
    required String date,
    required String time,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.saveScan);
      final request = http.MultipartRequest('POST', url);

      request.fields['userId'] = userId;
      request.fields['fishName'] = fishName;
      request.fields['category'] = category;
      request.fields['percentage'] = percentage.toString();
      request.fields['area'] = area;
      request.fields['scanDate'] = date;
      request.fields['scanTime'] = time;

      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();

      final multipartFile = http.MultipartFile(
        'fishImage',
        stream,
        length,
        filename: path.basename(imageFile.path),
      );

      request.files.add(multipartFile);
      return await request.send();
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> saveScanFromAnalysis({
    required File imageFile,
    required String detectedLabel,
    required double confidence,
    required String scanArea,
  }) async {
    if (!UserSession.isLoggedIn) return false;

    final normalizedLabel = detectedLabel.toLowerCase();
    if (normalizedLabel == 'data_invalid' ||
        normalizedLabel == 'invalid_data' ||
        confidence < 0.4) {
      return false;
    }

    final parts = detectedLabel.split('_');
    final species = parts.isNotEmpty ? parts[0].toUpperCase() : 'UNKNOWN';
    final status = parts.length > 1 ? parts[1].toUpperCase() : 'UNKNOWN';

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

      final body = await response.stream.bytesToString();
      debugPrint(
        '[ScanService] Save response ${response.statusCode}: $body',
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('[ScanService] Save failed: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getUserScanHistory(String userId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/scan/history/$userId');
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          "Failed loading history logs from server pipeline backend.",
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
