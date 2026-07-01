import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_sizes.dart';
import '../../services/tflite_service.dart';
import '../result/result_screen.dart';

class AnalyzingScreen extends StatefulWidget {
  final File image;
  const AnalyzingScreen({super.key, required this.image});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TFLiteService _tfLiteService = TFLiteService();

  int _stepIndex = 0;
  final List<String> _progressSteps = const [
    "Warming up engine...",
    "Pre-processing fish image...",
    "Analyzing biological markers...",
    "Calculating freshness score...",
    "Finalizing report...",
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _performFullInference();
  }

  Future<void> _performFullInference() async {
    try {
      // Step 0: Load Model
      setState(() => _stepIndex = 0);
      await _tfLiteService.loadModel();
      await Future.delayed(const Duration(milliseconds: 800));

      // Step 1: Pre-processing
      if (!mounted) return;
      setState(() => _stepIndex = 1);
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: Run the Model (Actual Inference)
      setState(() => _stepIndex = 2);
      // 'result' should contain {'label': 'pomfret_fresh', 'score': 0.85}
      final result = await _tfLiteService.predictFreshness(widget.image);

      // Step 3: Logic Processing
      setState(() => _stepIndex = 3);
      await Future.delayed(const Duration(milliseconds: 600));

      // Step 4: Finalizing
      setState(() => _stepIndex = 4);
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      // NAVIGATE TO RESULT SCREEN
      // We pass the raw label and score. ResultScreen handles the splitting/invalid check.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            image: widget.image,
            detectedLabel: result['label'] ?? "invalid_data",
            confidence: result['score'] ?? 0.0,
            scanArea: "Eye & Gills", // You can customize this per fish
          ),
        ),
      );
    } catch (e) {
      debugPrint("Analysis Error: $e");
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progressValue = (_stepIndex + 1) / _progressSteps.length;
    const primaryBlue = Color(0xFF1A5694);
    const accentTeal = Color(0xFF2CB88E);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedLoader(context, _controller, progressValue, accentTeal),
          SizedBox(height: rsh(context, 40)),
          Text(
            "Analyzing Freshness",
            style: GoogleFonts.poppins(
              fontSize: rs(context, 20),
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          SizedBox(height: rsh(context, 6)),
          Text(
            "Inspecting freshness details...",
            style: GoogleFonts.poppins(
              fontSize: rs(context, 13),
              color: Colors.blueGrey.shade300,
            ),
          ),
          SizedBox(height: rsh(context, 32)),
          _buildProgressTile(context, primaryBlue, accentTeal, progressValue),
        ],
      ),
    );
  }

  Widget _buildAnimatedLoader(
    BuildContext context,
    AnimationController controller,
    double progress,
    Color accent,
  ) {
    final outerSize = rs(context, 170);
    final ringSize = rs(context, 150);
    final innerSize = rs(context, 105);
    final emojiSize = rs(context, 46);
    return Center(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: outerSize,
                width: outerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.05 + (controller.value * 0.05)),
                ),
              ),
              SizedBox(
                height: ringSize,
                width: ringSize,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
              Container(
                height: innerSize,
                width: innerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Transform.scale(
                    scale: 1.0 + (controller.value * 0.1),
                    child: Text("🐟", style: TextStyle(fontSize: emojiSize)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressTile(BuildContext context, Color primary, Color accent, double progress) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: rs(context, 36)),
      padding: EdgeInsets.symmetric(vertical: rsh(context, 14), horizontal: rs(context, 18)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          SizedBox(
            width: rs(context, 18),
            height: rs(context, 18),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2CB88E)),
            ),
          ),
          SizedBox(width: rs(context, 15)),
          Expanded(
            child: Text(
              _progressSteps[_stepIndex],
              style: GoogleFonts.poppins(
                fontSize: rs(context, 14),
                color: primary.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            "${(progress * 100).toInt()}%",
            style: GoogleFonts.poppins(
              fontSize: rs(context, 12),
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
