import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      builder: (_) => const PremiumSheet(),
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
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => _PaymentDialog(
        plan: _selectedPlan == 'business' ? 'Business' : _yearlySelected ? 'Yearly' : 'Monthly',
        price: _selectedPlan == 'business' ? 'Rs. 5,000/month' : _yearlySelected ? 'Rs. 2,999/year' : 'Rs. 500/month',
      ),
    );
    if (confirmed != true) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', true);
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
                            const SizedBox(height: 20),
                            _buildSocialProof(),
                            const SizedBox(height: 24),
                            _buildComparisonTable(),
                            const SizedBox(height: 24),
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

  // ── Social proof ─────────────────────────────────────────────────────────

  Widget _buildSocialProof() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Avatar stack
        SizedBox(
          width: 64,
          height: 26,
          child: Stack(
            children: List.generate(3, (i) => Positioned(
              left: i * 18.0,
              child: Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: [_blue, _ocean, _teal][i],
                  border: Border.all(color: const Color(0xFF061A30), width: 2),
                ),
                child: Icon(Icons.person_rounded, color: Colors.white.withOpacity(0.8), size: 14),
              ),
            )),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "Trusted by 500+ fish vendors across Pakistan",
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.45),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ── Comparison table ─────────────────────────────────────────────────────

  Widget _buildComparisonTable() {
    final rows = [
      ("Daily Scans",        "15 scans",     "Unlimited",   "Unlimited"),
      ("AI Freshness Check", "✓",            "✓",           "✓"),
      ("Scan History",       "Last 10 only", "Full history", "Full history"),
      ("Export Reports",     "✗",            "PDF export",   "PDF + Excel"),
      ("Priority Analysis",  "✗",            "✓",           "✓"),
      ("Ads",                "Shown",        "Ad-free",      "Ad-free"),
      ("Vendor Badge",       "✗",            "✗",           "✓ Certified"),
      ("API Access",         "✗",            "✗",           "✓ Included"),
      ("Support",            "Community",    "Email",        "Dedicated"),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Column(
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: [
                    const Expanded(flex: 3, child: SizedBox()),
                    Expanded(flex: 2, child: Text("Free",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600))),
                    Expanded(flex: 2, child: Text("Premium",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: _teal, fontSize: 11, fontWeight: FontWeight.w700))),
                    Expanded(flex: 2, child: Text("Business",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: const Color(0xFFFFB74D), fontSize: 11, fontWeight: FontWeight.w700))),
                  ],
                ),
              ),
              Divider(color: Colors.white.withOpacity(0.07), height: 1),
              ...rows.asMap().entries.map((e) {
                final i = e.key;
                final r = e.value;
                return Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(r.$1,
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11))),
                        Expanded(flex: 2, child: Text(r.$2,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: r.$2 == "✗" ? Colors.white24 : Colors.white38,
                            fontSize: 10))),
                        Expanded(flex: 2, child: Text(r.$3,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: r.$3 == "✗" ? Colors.white24 : _teal,
                            fontSize: 10, fontWeight: FontWeight.w600))),
                        Expanded(flex: 2, child: Text(r.$4,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: r.$4 == "✗" ? Colors.white24 : const Color(0xFFFFB74D),
                            fontSize: 10, fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                  if (i < rows.length - 1)
                    Divider(color: Colors.white.withOpacity(0.05), height: 1, indent: 16, endIndent: 16),
                ]);
              }),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  // ── Plan toggle ──────────────────────────────────────────────────────────

  Widget _buildPlanToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Choose a plan",
          style: GoogleFonts.poppins(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _planCard(type: "monthly")),
            const SizedBox(width: 10),
            Expanded(child: _planCard(type: "yearly")),
            const SizedBox(width: 10),
            Expanded(child: _planCard(type: "business")),
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
                "Save 50% vs monthly with yearly",
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

  // "type" is "monthly" | "yearly" | "business"
  String _selectedPlan = "yearly";

  Widget _planCard({required String type}) {
    final selected = _selectedPlan == type;
    final isYearly = type == "yearly";
    final isBusiness = type == "business";

    final label = isBusiness ? "Business" : isYearly ? "Yearly" : "Monthly";
    final price = isBusiness ? "Rs. 417" : isYearly ? "Rs. 250" : "Rs. 500";
    final sub   = isBusiness ? "Rs. 5,000/mo" : isYearly ? "Rs. 2,999/yr" : "/month";
    final badge = isBusiness ? "B2B" : isYearly ? "BEST VALUE" : null;
    final badgeColor = isBusiness ? const Color(0xFFFFB74D) : _teal;
    final accentColor = isBusiness ? const Color(0xFFFFB74D) : _teal;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedPlan = type;
        _yearlySelected = isYearly;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? accentColor : Colors.white.withOpacity(0.12),
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: accentColor.withOpacity(0.18), blurRadius: 16)]
              : [],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badge != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: badgeColor.withOpacity(0.5)),
                    ),
                    child: Text(badge,
                      style: GoogleFonts.poppins(
                        color: badgeColor, fontSize: 7,
                        fontWeight: FontWeight.bold, letterSpacing: 0.4)),
                  )
                else
                  const SizedBox(height: 20),
                Text(label,
                  style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(price,
                  style: GoogleFonts.poppins(
                    color: selected ? accentColor : Colors.white60,
                    fontSize: 15, fontWeight: FontWeight.bold)),
                Text(sub,
                  style: GoogleFonts.poppins(color: Colors.white30, fontSize: 8)),
              ],
            ),
            if (selected)
              Positioned(
                top: 0, right: 0,
                child: Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 10),
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
              _selectedPlan == "business"
                  ? "Start Business Plan — Rs. 5,000/mo"
                  : _selectedPlan == "yearly"
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

class PremiumSheet extends StatefulWidget {
  const PremiumSheet({super.key});

  @override
  State<PremiumSheet> createState() => _PremiumSheetState();
}

class _PremiumSheetState extends State<PremiumSheet> {
  bool _yearlySelected = true;

  static const _blue = Color(0xFF1A5694);
  static const _teal = Color(0xFF2CB88E);
  static const _ocean = Color(0xFF0891B2);

  Future<void> _subscribe() async {
    if (!mounted) return;
    // Show payment dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => _PaymentDialog(
        plan: _yearlySelected ? 'Yearly' : 'Monthly',
        price: _yearlySelected ? 'Rs. 2,999/year' : 'Rs. 500/month',
      ),
    );
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium', true);
      await prefs.setBool('premium_seen', true);
      if (!mounted) return;
      Navigator.pop(context);
    }
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

// ── Payment dialog ────────────────────────────────────────────────────────────

class _PaymentDialog extends StatefulWidget {
  final String plan;
  final String price;

  const _PaymentDialog({required this.plan, required this.price});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _cardCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _processing = false;

  static const _blue = Color(0xFF1A5694);
  static const _teal = Color(0xFF2CB88E);

  @override
  void dispose() {
    _cardCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (_cardCtrl.text.replaceAll(' ', '').length < 16 ||
        _expiryCtrl.text.length < 5 ||
        _cvvCtrl.text.length < 3 ||
        _nameCtrl.text.trim().isEmpty) {
      return;
    }
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D2E5C), Color(0xFF0891B2), Color(0xFF2CB88E)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_rounded, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text("Secure Payment",
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 12)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white60, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${widget.plan} Plan",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.price,
                    style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.75), fontSize: 13),
                  ),
                ],
              ),
            ),
            // Form
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _field("Cardholder Name", Icons.person_rounded, _nameCtrl,
                      TextInputType.name),
                  const SizedBox(height: 14),
                  _field("Card Number", Icons.credit_card_rounded, _cardCtrl,
                      TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CardNumberFormatter(),
                      ],
                      maxLength: 19),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                          child: _field("MM/YY", Icons.date_range_rounded,
                              _expiryCtrl, TextInputType.number,
                              inputFormatters: [_ExpiryFormatter()],
                              maxLength: 5)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _field("CVV", Icons.security_rounded, _cvvCtrl,
                              TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLength: 3,
                              obscure: true)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _processing ? null : _pay,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A5694), Color(0xFF0891B2), Color(0xFF2CB88E)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: _teal.withOpacity(0.28),
                              blurRadius: 14,
                              offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Center(
                        child: _processing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : Text(
                                "Pay ${widget.price}",
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_rounded,
                          size: 13, color: _blue.withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Text("256-bit SSL encrypted · Secure checkout",
                          style: GoogleFonts.poppins(
                              color: Colors.grey.shade400, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    IconData icon,
    TextEditingController ctrl,
    TextInputType type, {
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    bool obscure = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1A5694)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
            fontSize: 12, color: Colors.blueGrey.shade400),
        prefixIcon: Icon(icon, color: _blue, size: 18),
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF4F7FB),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: _blue.withOpacity(0.4), width: 1.5)),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue newVal) {
    final digits = newVal.text.replaceAll(' ', '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final str = buf.toString();
    return newVal.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue newVal) {
    var digits = newVal.text.replaceAll('/', '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buf.write('/');
      buf.write(digits[i]);
    }
    final str = buf.toString();
    return newVal.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

