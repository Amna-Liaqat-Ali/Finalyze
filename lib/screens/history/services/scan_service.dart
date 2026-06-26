import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../core/api_config.dart';
import '../../../core/local_image_store.dart';
import '../../../core/user_session.dart';

class ScanService {
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
    final tempId = 'tmp_${now.millisecondsSinceEpoch}';

    try {
      if (!await imageFile.exists()) return false;

      // Step 1: Save image locally immediately (no network, instant)
      await LocalImageStore.saveImage(imageFile, tempId);

      // Step 2: Send metadata only to backend (no image = fast)
      final response = await http.post(
        Uri.parse(ApiConfig.saveScan),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': UserSession.userId,
          'fishName': species,
          'category': status,
          'percentage': confidence * 100,
          'area': scanArea,
          'scanDate': DateFormat('yyyy-MM-dd').format(now),
          'scanTime': DateFormat('hh:mm:ss a').format(now),
          'imageData': 'local',
        }),
      ).timeout(const Duration(seconds: 15));

      debugPrint('[ScanService] Save response ${response.statusCode}');

      if (response.statusCode == 201) {
        // Step 3: Remap temp image to real scan ID in background
        final data = jsonDecode(response.body);
        final scanId = data['scan']?['_id'] as String?;
        if (scanId != null) {
          LocalImageStore.link(tempId, scanId);
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[ScanService] Save failed: $e');
      return false;
    }
  }

  static Future<bool> deleteScan(String scanId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/scan/$scanId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        LocalImageStore.deleteImage(scanId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[ScanService] Delete failed: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getUserScanHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/scan/history/$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      debugPrint('[ScanService] History load failed: $e');
      return [];
    }
  }

  static Future<File?> getScanImageFile(String scanId) async {
    return LocalImageStore.getImage(scanId);
  }
}
