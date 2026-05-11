import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tflite_v2/tflite_v2.dart';

class TFLiteService {
  bool _isModelLoaded = false;

  static const String modelPath = 'assets/model/fish_model_update.tflite';
  static const String labelPath = 'assets/model/labels.txt';

  Future<void> loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: modelPath,
        labels: labelPath,
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false,
      );
      _isModelLoaded = res != null;
      debugPrint("Model loaded: $res");
    } catch (e) {
      debugPrint("Error loading model: $e");
    }
  }

  Future<Map<String, dynamic>> predictFreshness(File imageFile) async {
    if (!_isModelLoaded) await loadModel();

    try {
      var recognitions = await Tflite.runModelOnImage(
        path: imageFile.path,
        numResults: 3,
        threshold: 0.05,
        imageMean: 127.5,
        imageStd: 127.5,
        asynch: true,
      );

      print("AI Raw Output: $recognitions");

      if (recognitions == null || recognitions.isEmpty) {
        throw Exception("AI returned no results");
      }

      var bestMatch = recognitions[0];
      String label = bestMatch['label'];
      double confidence = (bestMatch['confidence'] as double) * 100;
      int index = bestMatch['index'];

      return {
        "status": label,
        "score": confidence,
        "freshness": index == 0 ? 95.0 : (index == 1 ? 60.0 : 20.0),
      };
    } catch (e) {
      debugPrint("Inference Error: $e");
      return {"status": "Error", "score": 0.0, "freshness": 0.0};
    }
  }

  void dispose() {
    Tflite.close();
    _isModelLoaded = false;
  }
}
