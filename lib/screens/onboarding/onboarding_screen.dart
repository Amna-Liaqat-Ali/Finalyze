import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Main/MainScreen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  static const _pages = [
    _OnboardingData(
      icon: Icons.camera_alt_rounded,
      badge: "STEP 1",
      title: "Scan Fish\nInstantly",
      subtitle:
          "Point your camera at any fish. Our AI reads the eyes, gills, and skin in seconds.",
      gradient: [Color(0xFF0D2E5C), Color(0xFF1A5694), Color(0xFF0891B2)],
      accentColor: Color(0xFF2CB88E),
    ),
    _OnboardingData(
      icon: Icons.biotech_rounded,
      badge: "STEP 2",
      title: "AI-Powered\nAnalysis",
      subtitle:
          "Advanced deep-learning model evaluates biological markers to detect freshness with high precision.",
      gradient: [Color(0xFF0A3D2E), Color(0xFF0D6E50), Color(0xFF2CB88E)],
      accentColor: Color(0xFF0891B2),
    ),
    _OnboardingData(
      icon: Icons.analytics_rounded,
      badge: "STEP 3",
      title: "Clear, Trusted\nResults",
      subtitle:
          "Get freshness status, confidence score, species info, and cooking recommendations instantly.",
      gradient: [Color(0xFF1A0A3D), Color(0xFF3B1A8C), Color(0xFF6C3FC1)],
      accentColor: Color(0xFF2CB88E),
    ),
    _OnboardingData(
      icon: Icons.history_edu_rounded,
      badge: "STEP 4",
      title: "Track Every\nScan",
      subtitle:
          "Your scan history is saved securely. Review past results and monitor fish quality over time.",
      gradient: [Color(0xFF0D2E5C), Color(0xFF0891B2), Color(0xFF2CB88E)],
      accentColor: Color(0xFFFFD700),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _animateIn();
  }

  void _animateIn() {
    _fadeCtrl.forward(from: 0);
    _slideCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < _pages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 420), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _finish() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const MainScreen(),
        transitionsBuilder: (_, a, __, child) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: a,
            child: SlideTransition(position: slide, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 550),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentIndex];
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: page.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child: Image.asset('assets/icon/app_icon.png',
                              width: 28, height: 28, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'FINALYZE',
                          style: GoogleFonts.lexend(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) {
                    setState(() => _currentIndex = i);
                    _animateIn();
                  },
                  itemBuilder: (_, i) => _buildPage(_pages[i]),
                ),
              ),

              // Dots + button
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(24, 0, 24, 36),
                child: Column(
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: _currentIndex == i ? 28 : 6,
                          decoration: BoxDecoration(
                            color: _currentIndex == i
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // CTA button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: page.gradient.first,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _currentIndex == _pages.length - 1
                              ? "Get Started"
                              : "Next",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: page.gradient.first,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingData data) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon card
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2), width: 1.5),
                ),
                child: Icon(data.icon, color: Colors.white, size: 46),
              ),
              const SizedBox(height: 32),
              // Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: data.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: data.accentColor.withOpacity(0.4), width: 1),
                ),
                child: Text(
                  data.badge,
                  style: GoogleFonts.poppins(
                    color: data.accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                data.title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                data.subtitle,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.70),
                  fontSize: 15,
                  height: 1.65,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),
              // Accent line
              Container(
                width: 48,
                height: 3,
                decoration: BoxDecoration(
                  color: data.accentColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String badge;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final Color accentColor;

  const _OnboardingData({
    required this.icon,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.accentColor,
  });
}
