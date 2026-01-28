import 'dart:async';

import 'package:fish_freshness_detection/screens/Main/main_screen.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import 'onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  bool _animatePage = false;

  final List<Map<String, dynamic>> pages = [
    {
      "icon": Icons.camera_alt_rounded,
      "title": "Scan Fish Instantly",
      "desc":
          "Capture or upload an image of fish to analyze its freshness in seconds using advanced AI technology.",
    },
    {
      "icon": Icons.psychology_alt_rounded,
      "title": "AI-Powered Analysis",
      "desc":
          "Our smart AI evaluates visual indicators like color, texture, and clarity for accurate freshness detection.",
    },
    {
      "icon": Icons.analytics_rounded,
      "title": "Clear Freshness Results",
      "desc":
          "View easy-to-understand freshness status, confidence score, and useful handling recommendations.",
    },
    {
      "icon": Icons.history_rounded,
      "title": "Track Scan History",
      "desc":
          "All your scans are saved securely, helping you track and compare fish freshness over time.",
    },
  ];

  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 300), () {
      setState(() => _animatePage = true);
    });
  }

  void _next() {
    if (_currentIndex < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, animation, secondaryAnimation) => const MainScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );

          final slide =
              Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              );

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(onPressed: _finish, child: const Text("Skip")),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _animatePage = false;
                  });
                  Timer(const Duration(milliseconds: 200), () {
                    setState(() => _animatePage = true);
                  });
                },
                itemBuilder: (_, index) {
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    opacity: _animatePage ? 1.0 : 0.0,
                    curve: Curves.easeIn,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 600),
                      scale: _animatePage ? 1.0 : 0.8,
                      curve: Curves.easeOutBack,
                      child: OnboardingPage(
                        icon: pages[index]["icon"],
                        title: pages[index]["title"],
                        description: pages[index]["desc"],
                      ),
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentIndex == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        _currentIndex == pages.length - 1
                            ? "Get Started"
                            : "Next",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
