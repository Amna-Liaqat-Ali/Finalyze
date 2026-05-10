import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/tflite_service.dart'; // Ensure this path is correct
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
    "Warming up AI engine...",
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

      // Step 1 & 2: Image Processing
      if (!mounted) return;
      setState(() => _stepIndex = 1);

      // Step 3: Run the Model (Actual Inference)
      setState(() => _stepIndex = 2);
      final result = await _tfLiteService.predictFreshness(widget.image);

      // Step 4: Logic Processing
      setState(() => _stepIndex = 3);
      await Future.delayed(const Duration(milliseconds: 600));

      // Step 5: Wrap up
      setState(() => _stepIndex = 4);
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      // Navigate with REAL data from model
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            image: widget.image,
            status: result['status'], // "Fresh", "Moderate", etc.
            confidence: result['score'], // Confidence %
            freshnessScore: result['freshness'], // Score %
          ),
        ),
      );
    } catch (e) {
      debugPrint("Analysis Error: $e");
      if (mounted) Navigator.pop(context); // Go back on error
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
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentTeal.withOpacity(
                          0.05 + (_controller.value * 0.05),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 160,
                      width: 160,
                      child: CircularProgressIndicator(
                        value: progressValue,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          accentTeal,
                        ),
                      ),
                    ),
                    Container(
                      height: 110,
                      width: 110,
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
                          scale: 1.0 + (_controller.value * 0.1),
                          child: const Text(
                            "🐟",
                            style: TextStyle(fontSize: 50),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 50),
          Text(
            "Analyzing Freshness",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Our AI is inspecting details...",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.blueGrey.shade300,
            ),
          ),
          const SizedBox(height: 40),
          _buildProgressTile(primaryBlue, accentTeal, progressValue),
        ],
      ),
    );
  }

  Widget _buildProgressTile(Color primary, Color accent, double progress) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2CB88E)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              _progressSteps[_stepIndex],
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: primary.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            "${(progress * 100).toInt()}%",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
