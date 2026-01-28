import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    // Simulate the 5 steps of analysis
    for (int i = 0; i < _progressSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() => _stepIndex = i);
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(image: widget.image)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progressValue = (_stepIndex + 1) / _progressSteps.length;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D2B45), Color(0xFF163E5F), Color(0xFF005C7A)],
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. ANIMATED LOADER
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse Ring
                    Container(
                      height: 160,
                      width: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(
                          0.05 + (_controller.value * 0.05),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 140,
                      width: 140,
                      child: CircularProgressIndicator(
                        value: progressValue,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.cyanAccent, // Updated color to match theme
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: math.sin(_controller.value * 2 * math.pi) * 0.15,
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 50),

            const Text(
              "Analyzing Fish...",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "AI is detecting freshness features",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _controller,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.cyanAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.cyanAccent, blurRadius: 6),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Animated Text Step
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: Text(
                    _progressSteps[_stepIndex],
                    key: ValueKey(_progressSteps[_stepIndex]),
                    style: const TextStyle(fontSize: 15, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
