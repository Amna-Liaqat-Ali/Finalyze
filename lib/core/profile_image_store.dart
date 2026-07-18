import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's chosen profile picture to app storage so it survives
/// app restarts, until the user changes or removes it again.
class ProfileImageStore {
  static const _pathKey = 'profile_image_path';

  static Future<Directory> get _dir async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/profile_image');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Copies [source] into persistent storage and remembers its path.
  static Future<File?> saveImage(File source) async {
    try {
      final dir = await _dir;
      final path = '${dir.path}/profile.jpg';
      final saved = await source.copy(path);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pathKey, path);
      return saved;
    } catch (e) {
      debugPrint('[ProfileImageStore] save error: $e');
      return null;
    }
  }

  static Future<File?> getImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString(_pathKey);
      if (path != null) {
        final f = File(path);
        if (await f.exists()) return f;
      }
    } catch (e) {
      debugPrint('[ProfileImageStore] get error: $e');
    }
    return null;
  }

  static Future<void> deleteImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString(_pathKey);
      if (path != null) {
        final f = File(path);
        if (await f.exists()) await f.delete();
      }
      await prefs.remove(_pathKey);
    } catch (e) {
      debugPrint('[ProfileImageStore] delete error: $e');
    }
  }
}
