import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tflite_v2/tflite_v2.dart';

class TFLiteService {
  bool _isModelLoaded = false;

  // Hardcoded Model Config
  static const String modelPath = 'assets/model/fish_model_update.tflite';
  // Note: tflite_v2 handles labels.txt via a separate file if available
  static const String labelPath = 'assets/model/labels.txt';

  Future<void> loadModel() async {
    try {
      // tflite_v2 uses a static method to load the model
      String? res = await Tflite.loadModel(
        model: modelPath,
        labels: labelPath, // Create a labels.txt with: Fresh, Moderate, Spoiled
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
      // 1. Run model directly on the image path
      // No manual resizing or byte conversion needed!
      var recognitions = await Tflite.runModelOnImage(
        path: imageFile.path,
        numResults: 3,
        threshold:
            0.05, // Lower this to 0.05 to see if it's just a low confidence issue
        imageMean: 127.5, // Try 0.0 if this doesn't work
        imageStd: 127.5, // Try 255.0 if this doesn't work
        asynch: true,
      );

      print("AI Raw Output: $recognitions");

      if (recognitions == null || recognitions.isEmpty) {
        throw Exception("AI returned no results");
      }

      // 2. Extract results from the first prediction
      // Format returned: [{"confidence": 0.98, "index": 0, "label": "Fresh"}]
      var bestMatch = recognitions[0];
      String label = bestMatch['label'];
      double confidence = (bestMatch['confidence'] as double) * 100;
      int index = bestMatch['index'];

      return {
        "status": label,
        "score": confidence, // Confidence %
        "freshness": index == 0
            ? 95.0
            : (index == 1 ? 60.0 : 20.0), // Map to your UI scores
      };
    } catch (e) {
      debugPrint("Inference Error: $e");
      return {"status": "Error", "score": 0.0, "freshness": 0.0};
    }
  }

  // Very important: tflite_v2 needs to be closed to free up native memory
  void dispose() {
    Tflite.close();
    _isModelLoaded = false;
  }
}
