import 'package:fish_freshness_detection/screens/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../widgets/splash_loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addListener(() {
            setState(() {});
          });

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToHome();
      }
    });
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final slide = Tween(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(animation);

          final fade = Tween(begin: 0.0, end: 1.0).animate(animation);

          return SlideTransition(
            position: slide,
            child: FadeTransition(opacity: fade, child: child),
          );
        },
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.splashGradient),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Icon(Icons.set_meal, color: Colors.white, size: 40),
                ),

                Column(
                  children: [
                    const Icon(Icons.set_meal, size: 90, color: Colors.white),
                    const SizedBox(height: 25),

                    const Text(
                      "Finalyze",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      "Your Smart Guide to Fresh Seafood",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 35),

                    SplashLoader(progress: _controller.value),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Built for FYP by Amna",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
