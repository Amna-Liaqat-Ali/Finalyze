import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tflite_v2/tflite_v2.dart';

class TFLiteService {
  bool _isModelLoaded = false;

  static const String modelPath = 'assets/model/fish_file_11.tflite';
  static const String labelPath = 'assets/model/labels.txt';

  Future<void> loadModel() async {
    if (_isModelLoaded) return;
    try {
      String? res = await Tflite.loadModel(
        model: modelPath,
        labels: labelPath,
        numThreads: 4,
        isAsset: true,
        useGpuDelegate: true,
      );
      _isModelLoaded = res != null;
      debugPrint("Model loaded successfully");
    } catch (e) {
      debugPrint("Error loading model: $e");
    }
  }

  Future<Map<String, dynamic>> predictFreshness(File imageFile) async {
    if (!_isModelLoaded) await loadModel();

    try {
      var recognitions = await Tflite.runModelOnImage(
        path: imageFile.path,
        numResults: 1,
        threshold: 0.1,
        imageMean: 0,
        imageStd: 255.0,
        asynch: true,
      );

      debugPrint("AI Raw Output: $recognitions");

      if (recognitions == null || recognitions.isEmpty) {
        return {"label": "data_invalid", "score": 0.0};
      }

      var bestMatch = recognitions[0];

      return {
        "label": bestMatch['label'] ?? "invalid_data",
        "score": (bestMatch['confidence'] as double),
      };
    } catch (e) {
      debugPrint("Inference Error: $e");
      return {"label": "data_invalid", "score": 0.0};
    }
  }

  void dispose() {
    Tflite.close();
    _isModelLoaded = false;
  }
}
