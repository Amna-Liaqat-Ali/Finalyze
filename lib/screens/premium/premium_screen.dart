import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Main/MainScreen.dart';

class PremiumScreen extends StatefulWidget {
  /// If true, screen was opened from inside the app (e.g. Settings).
  /// If false, it was shown automatically and "Continue Free" skips to home.
  final bool standalone;

  const PremiumScreen({super.key, this.standalone = false});

  /// Show premium as a dismissible bottom sheet. Marks seen on close.
  static Future<void> showAsSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => const _PremiumSheet(),
    );
    // After sheet closes (either by dismiss or subscribe), mark seen & go home
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('premium_seen') ?? false;
    if (!seen) await prefs.setBool('premium_seen', true);
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (_) => false,
    );
  }

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with TickerProviderStateMixin {
  bool _yearlySelected = true;

  late final AnimationController _fadeCtrl;
  late final AnimationController _slideCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  static const _blue = Color(0xFF1A5694);
  static const _teal = Color(0xFF2CB88E);
  static const _ocean = Color(0xFF0891B2);

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeCtrl.forward();
      _slideCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _markSeenAndGoHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('premium_seen', true);
    if (!mounted) return;
    if (widget.standalone) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _subscribe() async {
    // TODO: wire up real in-app purchase here
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', true);
    await prefs.setBool('premium_seen', true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Premium activated! Enjoy unlimited scans.",
            style: GoogleFonts.poppins()),
        backgroundColor: _teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    if (widget.standalone) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF061A30),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Ocean background ──────────────────────────────────────────────
          Image.asset(
            'assets/images/splash_bg.jpeg',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          // Dark overlay gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC061A30),
                  Color(0xE8061A30),
                  Color(0xFA061A30),
                  Color(0xFF061A30),
                ],
                stops: [0.0, 0.35, 0.65, 1.0],
              ),
            ),
          ),
          // ── Content ───────────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    _buildTopBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            _buildHeroSection(size),
                            const SizedBox(height: 28),
                            _buildFeatureList(),
                            const SizedBox(height: 28),
                            _buildPlanToggle(),
                            const SizedBox(height: 28),
                            _buildCTA(),
                            const SizedBox(height: 16),
                            _buildSkipLink(),
                            const SizedBox(height: 12),
                            _buildFooterLinks(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top bar (close for standalone, empty for auto-show) ──────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (widget.standalone)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white70, size: 18),
              ),
            )
          else
            const SizedBox(width: 38),
          const Spacer(),
          _pillBadge("LIMITED OFFER", const Color(0xFFFFB74D)),
          const Spacer(),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _pillBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ── Hero section ─────────────────────────────────────────────────────────

  Widget _buildHeroSection(Size size) {
    return Column(
      children: [
        // Crown icon with glow
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _teal.withOpacity(0.30),
                    _blue.withOpacity(0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A5694), Color(0xFF0891B2), Color(0xFF2CB88E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _teal.withOpacity(0.45),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: Colors.white, size: 36),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          "Unlock Premium",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Scan unlimited fish with full AI power.\nNo restrictions, no limits.",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.60),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Feature list ─────────────────────────────────────────────────────────

  Widget _buildFeatureList() {
    final features = [
      (Icons.all_inclusive_rounded, "Unlimited fish scans", "Scan as many as you need, anytime"),
      (Icons.bolt_rounded, "Priority AI analysis", "Faster processing & higher accuracy"),
      (Icons.history_rounded, "Full scan history", "Unlimited history with export support"),
      (Icons.analytics_rounded, "Detailed freshness reports", "In-depth breakdown with recommendations"),
      (Icons.no_accounts_rounded, "No ads, ever", "Clean experience, completely ad-free"),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Column(
            children: features.asMap().entries.map((entry) {
              final i = entry.key;
              final f = entry.value;
              return Column(
                children: [
                  _featureRow(f.$1, f.$2, f.$3),
                  if (i < features.length - 1)
                    Divider(
                      color: Colors.white.withOpacity(0.06),
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _teal.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _teal, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  )),
                Text(subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 11,
                  )),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: _teal, size: 18),
        ],
      ),
    );
  }

  // ── Plan toggle ──────────────────────────────────────────────────────────

  Widget _buildPlanToggle() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _planCard(yearly: false)),
            const SizedBox(width: 12),
            Expanded(child: _planCard(yearly: true)),
          ],
        ),
        if (_yearlySelected) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.savings_rounded, color: Color(0xFF4EE3AA), size: 14),
              const SizedBox(width: 5),
              Text(
                "You save 50% with the yearly plan",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF4EE3AA),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _planCard({required bool yearly}) {
    final selected = _yearlySelected == yearly;

    return GestureDetector(
      onTap: () => setState(() => _yearlySelected = yearly),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? _teal : Colors.white.withOpacity(0.12),
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: _teal.withOpacity(0.18), blurRadius: 16, spreadRadius: 0)]
              : [],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (yearly)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A5694), Color(0xFF2CB88E)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "BEST VALUE",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 26),
                Text(
                  yearly ? "Yearly" : "Monthly",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: yearly ? "Rs. 250" : "Rs. 500",
                        style: GoogleFonts.poppins(
                          color: selected ? _teal : Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: yearly ? "\n/month" : "\n/month",
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (yearly)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Billed Rs. 2,999/yr",
                      style: GoogleFonts.poppins(
                        color: Colors.white30,
                        fontSize: 9,
                      ),
                    ),
                  ),
              ],
            ),
            // Selection indicator
            if (selected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: _teal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 11),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── CTA button ────────────────────────────────────────────────────────────

  Widget _buildCTA() {
    return GestureDetector(
      onTap: _subscribe,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A5694), Color(0xFF0891B2), Color(0xFF2CB88E)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _teal.withOpacity(0.38),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              _yearlySelected
                  ? "Start Yearly Plan — Rs. 2,999"
                  : "Start Monthly Plan — Rs. 500",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipLink() {
    return GestureDetector(
      onTap: _markSeenAndGoHome,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          widget.standalone ? "Maybe later" : "Continue for free",
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.40),
            fontSize: 13,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white30,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _footerLink("Restore Purchase"),
        Text("  ·  ",
            style: TextStyle(color: Colors.white.withOpacity(0.20))),
        _footerLink("Privacy Policy"),
        Text("  ·  ",
            style: TextStyle(color: Colors.white.withOpacity(0.20))),
        _footerLink("Terms of Use"),
      ],
    );
  }

  Widget _footerLink(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white.withOpacity(0.28),
        fontSize: 10,
        decoration: TextDecoration.underline,
        decorationColor: Colors.white24,
      ),
    );
  }
}

// ── Bottom-sheet variant (dismissible card) ──────────────────────────────────

class _PremiumSheet extends StatefulWidget {
  const _PremiumSheet();

  @override
  State<_PremiumSheet> createState() => _PremiumSheetState();
}

class _PremiumSheetState extends State<_PremiumSheet> {
  bool _yearlySelected = true;

  static const _blue = Color(0xFF1A5694);
  static const _teal = Color(0xFF2CB88E);
  static const _ocean = Color(0xFF0891B2);

  Future<void> _subscribe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', true);
    await prefs.setBool('premium_seen', true);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF061A30),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Stack(
            children: [
              // Ocean image clipped to rounded top
              Positioned.fill(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  child: Opacity(
                    opacity: 0.25,
                    child: Image.asset(
                      'assets/images/splash_bg.jpeg',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  // Drag handle
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      children: [
                        // Header row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _pillBadge("LIMITED OFFER", const Color(0xFFFFB74D)),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.10),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded,
                                    color: Colors.white60, size: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Crown icon
                        Center(
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [_blue, _ocean, _teal],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: _teal.withOpacity(0.4),
                                    blurRadius: 20),
                              ],
                            ),
                            child: const Icon(Icons.workspace_premium_rounded,
                                color: Colors.white, size: 32),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "Unlock Premium",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Unlimited scans · Full AI power · No ads",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 22),
                        // Feature bullets
                        ...[
                          (Icons.all_inclusive_rounded, "Unlimited fish scans"),
                          (Icons.bolt_rounded, "Priority AI analysis"),
                          (Icons.history_rounded, "Full scan history & export"),
                          (Icons.analytics_rounded, "Detailed freshness reports"),
                          (Icons.no_accounts_rounded, "No ads, ever"),
                        ].map((f) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: _teal.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(f.$1, color: _teal, size: 16),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    f.$2,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.check_circle_rounded,
                                      color: _teal, size: 16),
                                ],
                              ),
                            )),
                        const SizedBox(height: 22),
                        // Plan cards
                        Row(
                          children: [
                            Expanded(child: _planCard(yearly: false)),
                            const SizedBox(width: 12),
                            Expanded(child: _planCard(yearly: true)),
                          ],
                        ),
                        const SizedBox(height: 22),
                        // CTA
                        GestureDetector(
                          onTap: _subscribe,
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_blue, _ocean, _teal],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: _teal.withOpacity(0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 5)),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _yearlySelected
                                    ? "Start Yearly — Rs. 2,999"
                                    : "Start Monthly — Rs. 500",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              "Continue for free",
                              style: GoogleFonts.poppins(
                                color: Colors.white38,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _pillBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8),
      ),
    );
  }

  Widget _planCard({required bool yearly}) {
    final selected = _yearlySelected == yearly;
    return GestureDetector(
      onTap: () => setState(() => _yearlySelected = yearly),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withOpacity(0.12)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _teal : Colors.white.withOpacity(0.12),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (yearly)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_blue, _teal]),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text("BEST VALUE",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              )
            else
              const SizedBox(height: 22),
            Text(yearly ? "Yearly" : "Monthly",
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(
              yearly ? "Rs. 250/mo" : "Rs. 500/mo",
              style: GoogleFonts.poppins(
                  color: selected ? _teal : Colors.white60,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            if (yearly)
              Text("Rs. 2,999/yr",
                  style:
                      GoogleFonts.poppins(color: Colors.white30, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}
