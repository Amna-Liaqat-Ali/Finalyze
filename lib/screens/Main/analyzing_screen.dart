import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../result/models/analysis_result_model.dart';
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
  late Animation<double> _scaleAnimation;

  int _stepIndex = 0;

  final List<String> _progressSteps = const [
    "Preparing image",
    "Extracting visual features",
    "Running AI freshness model",
    "Calculating confidence score",
    "Finalizing result",
  ];

  @override
  void initState() {
    super.initState();

    // Pulsing animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    for (int i = 0; i < _progressSteps.length; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _stepIndex = i);
    }

    final result = AnalysisResult(
      isFresh: true,
      freshnessScore: 95,
      confidence: 98,
      location: "Karachi Fish Harbor",
      estimatedAge: "0–24 hours",
      dateTime: DateTime.now(),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          image: widget.image,
          result: result,
          dateTime: result.dateTime,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_stepIndex + 1) / _progressSteps.length;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.12),
                  ),
                  child: const Icon(
                    Icons.auto_graph_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                "Analyzing Image",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 14),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: Text(
                  _progressSteps[_stepIndex],
                  key: ValueKey(_progressSteps[_stepIndex]),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
