import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/colors.dart';
import '../Main/MainScreen.dart';
import '../premium/premium_screen.dart';
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
      if (mounted) setState(() => _animatePage = true);
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

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('premium_seen') ?? false;
    if (!mounted) return;
    if (seen) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      await PremiumScreen.showAsSheet(context);
    }
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
              child: TextButton(
                onPressed: _finish,
                child: const Text("Skip", style: TextStyle(color: Colors.grey)),
              ),
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
                    if (mounted) setState(() => _animatePage = true);
                  });
                },
                itemBuilder: (_, index) {
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    opacity: _animatePage ? 1.0 : 0.0,
                    curve: Curves.easeIn,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 600),
                      scale: _animatePage ? 1.0 : 0.9,
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
                        ? const Color(0xFF163E5F)
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
                    backgroundColor: const Color(0xFF163E5F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _currentIndex == pages.length - 1 ? "Get Started" : "Next",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
