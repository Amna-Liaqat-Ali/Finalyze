import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalImageStore {
  // Maps scanId -> local file path
  static const _prefPrefix = 'scan_img_';

  static Future<Directory> get _dir async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/scan_images');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Save compressed image, keyed by [id]. Returns local path.
  static Future<String?> saveImage(File imageFile, String id) async {
    try {
      final dir = await _dir;
      final path = '${dir.path}/$id.jpg';

      final Uint8List? compressed = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: 500,
        minHeight: 500,
        quality: 70,
      );

      await File(path).writeAsBytes(compressed ?? await imageFile.readAsBytes());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefPrefix$id', path);
      return path;
    } catch (e) {
      debugPrint('[LocalImageStore] save error: $e');
      return null;
    }
  }

  /// After backend returns real scanId, link it to an existing local file.
  static Future<void> link(String existingId, String scanId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingPath = prefs.getString('$_prefPrefix$existingId');
      if (existingPath != null) {
        // Point scanId to the same file
        await prefs.setString('$_prefPrefix$scanId', existingPath);
      }
    } catch (e) {
      debugPrint('[LocalImageStore] link error: $e');
    }
  }

  static Future<File?> getImage(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString('$_prefPrefix$id');
      if (path != null) {
        final f = File(path);
        if (await f.exists()) return f;
      }
      // Fallback: direct path
      final dir = await _dir;
      final f = File('${dir.path}/$id.jpg');
      if (await f.exists()) return f;
    } catch (e) {
      debugPrint('[LocalImageStore] get error: $e');
    }
    return null;
  }

  static Future<void> deleteImage(String id) async {
    try {
      final f = await getImage(id);
      if (f != null && await f.exists()) await f.delete();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefPrefix$id');
    } catch (_) {}
  }
}
