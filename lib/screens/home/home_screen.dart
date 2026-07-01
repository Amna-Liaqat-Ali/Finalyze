import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:Finalyze/screens/Blogs/widgets/blog_slider.dart';
import 'package:Finalyze/screens/history/history_screen.dart';
import 'package:Finalyze/screens/home/widgets/settings_screen.dart';
import 'package:Finalyze/screens/species/screens/specie_screen.dart';
import 'package:Finalyze/screens/species/widgets/species_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_sizes.dart';
import '../../core/scan_limit_service.dart';
import '../../core/user_session.dart';
import '../history/services/scan_service.dart';
import '../result/photo_edit_screen.dart';
import 'widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  static const _primaryBlue = Color(0xFF1A5694);
  static const _teal = Color(0xFF2CB88E);

  int _totalScans = 0;
  int _todayScans = 0;
  String _accuracy = '—';
  ScanLimitStatus? _scanLimit;
  Timer? _limitTimer;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadScanLimit();
    // Refresh scan limit every 30s so banner stays current
    _limitTimer = Timer.periodic(const Duration(seconds: 10), (_) => _loadScanLimit());
  }

  @override
  void dispose() {
    _limitTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadScanLimit() async {
    final status = await ScanLimitService.getStatus();
    if (!mounted) return;
    setState(() {
      _scanLimit = status;
      _todayScans = status.used;
    });
  }

  Future<void> _loadStats() async {
    try {
      final userId = UserSession.userId ?? '';
      if (userId.isEmpty) return;
      final rawData = await ScanService.getUserScanHistory(userId);
      if (!mounted) return;
      double totalConf = 0;
      for (final item in rawData) {
        final json = item as Map<String, dynamic>;
        totalConf += ((json['percentage'] ?? 0.0) as num).toDouble();
      }
      if (!mounted) return;
      setState(() {
        _totalScans = rawData.length;
        _accuracy = rawData.isEmpty
            ? '—'
            : '${(totalConf / rawData.length).round()}%';
      });
    } catch (_) {}
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (image == null) return;
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PhotoEditScreen(image: File(image.path))),
      );
      // Small delay to ensure backend has finished processing the scan increment
      await Future.delayed(const Duration(milliseconds: 600));
      _loadStats();
      _loadScanLimit();
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildWaveHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(rs(context, 20), rsh(context, 18), rs(context, 20), 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatCard(label: "Total Scans", value: "$_totalScans"),
                      StatCard(label: "Today Scans", value: "$_todayScans"),
                      StatCard(label: "Avg. Score", value: _accuracy),
                    ],
                  ),
                  SizedBox(height: rsh(context, 16)),
                  if (_scanLimit != null && !_scanLimit!.isPremium)
                    _buildScanLimitBanner(),
                  SizedBox(height: rsh(context, 16)),

                  _buildScanButton(),
                  SizedBox(height: rsh(context, 20)),

                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          Icons.upload_rounded,
                          "Upload Image",
                          () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                      SizedBox(width: rs(context, 15)),
                      Expanded(
                        child: _actionButton(Icons.history_rounded, "View History", () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryScreen(userId: ''),
                            ),
                          );
                          _loadStats();
                          _loadScanLimit();
                        }),
                      ),
                    ],
                  ),
                  SizedBox(height: rsh(context, 30)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Discover Species",
                        style: GoogleFonts.poppins(
                          fontSize: rs(context, 18),
                          fontWeight: FontWeight.bold,
                          color: _primaryBlue,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DiscoverSpeciesScreen(),
                          ),
                        ),
                        child: Text(
                          "View All",
                          style: GoogleFonts.poppins(
                            color: _teal,
                            fontWeight: FontWeight.w600,
                            fontSize: rs(context, 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: rsh(context, 15)),
                  const SpeciesSlider(),
                  SizedBox(height: rsh(context, 15)),
                  YouTubeBlogSlider(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveHeader(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        height: rsh(context, 200) + MediaQuery.of(context).padding.top,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fish/ocean background image
            Image.asset(
              'assets/images/splash_bg.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            // Dark gradient overlay so text stays readable
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0D2E5C).withOpacity(0.78),
                    const Color(0xFF0D47A1).withOpacity(0.65),
                    const Color(0xFF006994).withOpacity(0.55),
                    const Color(0xFF00897B).withOpacity(0.50),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Content
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(rs(context, 24), rsh(context, 20), rs(context, 20), rsh(context, 58)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            ClipOval(
                              child: Image.asset(
                                'assets/icon/app_icon.png',
                                width: rs(context, 22),
                                height: rs(context, 22),
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: rs(context, 6)),
                            Text(
                              'FINALYZE',
                              style: GoogleFonts.lexend(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: rs(context, 11),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 5,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          UserSession.name?.split(' ').first ?? 'Welcome',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: rs(context, 30),
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: rsh(context, 6)),
                        Text(
                          'Scan. Verify. Trust.',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: rs(context, 12),
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: rsh(context, 8)),
                        Container(
                          width: rs(context, 44),
                          height: rs(context, 2.5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.8),
                                Colors.white.withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      ),
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            width: rs(context, 48),
                            height: rs(context, 48),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                                width: 1.3,
                              ),
                            ),
                            child: Icon(
                              Icons.settings_outlined,
                              color: Colors.white,
                              size: rs(context, 21),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanLimitBanner() {
    final limit = _scanLimit!;
    final remaining = limit.remaining;
    final isFull = limit.isLimited;
    final color = isFull ? Colors.redAccent : (remaining <= 5 ? Colors.orange : _teal);

    return Builder(builder: (context) => Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rsh(context, 12)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(rs(context, 14)),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(
            isFull ? Icons.lock_clock_rounded : Icons.query_stats_rounded,
            color: color,
            size: rs(context, 20),
          ),
          SizedBox(width: rs(context, 12)),
          Expanded(
            child: isFull && limit.resetAt != null
                ? _ScanResetCountdown(resetAt: limit.resetAt!, color: color, onExpired: _loadScanLimit)
                : Text(
                    "$remaining / ${limit.max} scans remaining today",
                    style: GoogleFonts.poppins(
                      fontSize: rs(context, 12),
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
          ),
          if (!isFull)
            Container(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 10), vertical: rsh(context, 4)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(rs(context, 20)),
              ),
              child: Text(
                "${(remaining / limit.max * 100).toInt()}%",
                style: GoogleFonts.poppins(
                  fontSize: rs(context, 11),
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    ));
  }

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: () => _pickImage(ImageSource.camera),
      child: Container(
        width: double.infinity,
        height: rsh(context, 110),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(rs(context, 24)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.28),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(rs(context, 24)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(
                'assets/images/splash_bg.jpeg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
              // Gradient overlay — dark left, fade to teal right
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xDD0D2E5C),
                      Color(0xCC1565C0),
                      Color(0x880891B2),
                      Color(0x662CB88E),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              // Decorative bubbles
              Positioned(
                right: -18,
                top: -18,
                child: _bubble(80, Colors.white, 0.05),
              ),
              Positioned(
                right: 50,
                bottom: -20,
                child: _bubble(60, Colors.white, 0.04),
              ),
              // Content row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs(context, 24)),
                child: Row(
                  children: [
                    // Camera icon in frosted circle
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: rs(context, 64),
                          height: rs(context, 64),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: rs(context, 30),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: rs(context, 20)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Scan Fish Now',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: rs(context, 18),
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: rsh(context, 4)),
                          Text(
                            'AI-powered freshness analysis',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: rs(context, 11),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Arrow indicator
                    Container(
                      width: rs(context, 36),
                      height: rs(context, 36),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: rs(context, 14),
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

  Widget _bubble(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Builder(builder: (context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rs(context, 15)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: rsh(context, 15)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade100),
          borderRadius: BorderRadius.circular(rs(context, 15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.teal, size: rs(context, 20)),
            SizedBox(width: rs(context, 8)),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: rs(context, 13),
                color: const Color(0xFF1A5694),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class _ScanResetCountdown extends StatefulWidget {
  final DateTime resetAt;
  final Color color;
  final VoidCallback onExpired;
  const _ScanResetCountdown({required this.resetAt, required this.color, required this.onExpired});

  @override
  State<_ScanResetCountdown> createState() => _ScanResetCountdownState();
}

class _ScanResetCountdownState extends State<_ScanResetCountdown> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final diff = widget.resetAt.difference(DateTime.now());
    if (diff.isNegative || diff == Duration.zero) {
      _timer.cancel();
      widget.onExpired();
      return;
    }
    if (mounted) setState(() => _remaining = diff);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final h = _pad(_remaining.inHours);
    final m = _pad(_remaining.inMinutes.remainder(60));
    final s = _pad(_remaining.inSeconds.remainder(60));
    return Text(
      "Limit reached · resets in $h:$m:$s",
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: widget.color,
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 28);
    path.quadraticBezierTo(
      size.width * 0.2, size.height - 4,
      size.width * 0.45, size.height - 22,
    );
    path.quadraticBezierTo(
      size.width * 0.72, size.height - 40,
      size.width, size.height - 14,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}
