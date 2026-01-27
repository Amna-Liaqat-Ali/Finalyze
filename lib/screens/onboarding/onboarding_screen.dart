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

  void _next() {
    if (_currentIndex < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
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

            /// Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (_, index) {
                  return OnboardingPage(
                    icon: pages[index]["icon"],
                    title: pages[index]["title"],
                    description: pages[index]["desc"],
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
