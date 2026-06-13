import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../../../core/api_config.dart';

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
