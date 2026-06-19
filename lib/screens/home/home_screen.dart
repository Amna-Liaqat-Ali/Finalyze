import 'dart:io';
import 'dart:ui';

import 'package:Finalyze/screens/Blogs/widgets/blog_slider.dart';
import 'package:Finalyze/screens/history/history_screen.dart';
import 'package:Finalyze/screens/home/widgets/settings_screen.dart';
import 'package:Finalyze/screens/home/widgets/specie_screen.dart';
import 'package:Finalyze/screens/species/widgets/species_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final userId = UserSession.userId ?? '';
      if (userId.isEmpty) return;
      final rawData = await ScanService.getUserScanHistory(userId);
      if (!mounted) return;
      final today = DateTime.now();
      int todayCount = 0;
      double totalConf = 0;
      for (final item in rawData) {
        final json = item as Map<String, dynamic>;
        final dateStr = json['scanDate']?.toString() ?? '';
        try {
          final d = DateTime.parse(dateStr);
          if (d.year == today.year && d.month == today.month && d.day == today.day) {
            todayCount++;
          }
        } catch (_) {}
        totalConf += ((json['percentage'] ?? 0.0) as num).toDouble();
      }
      if (!mounted) return;
      setState(() {
        _totalScans = rawData.length;
        _todayScans = todayCount;
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PhotoEditScreen(image: File(image.path))),
      );
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
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
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
                  const SizedBox(height: 24),

                  _buildScanButton(),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          Icons.upload_rounded,
                          "Upload Image",
                          () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _actionButton(Icons.history_rounded, "View History", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryScreen(userId: ''),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Discover Species",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
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
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const SpeciesSlider(),
                  const SizedBox(height: 15),
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
        height: 210 + MediaQuery.of(context).padding.top,
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
                padding: const EdgeInsets.fromLTRB(24, 20, 20, 58),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'FINALYZE',
                          style: GoogleFonts.lexend(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 5,
                          ),
                        ),
                        Text(
                          UserSession.name?.split(' ').first ?? 'Welcome',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Scan. Verify. Trust.',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 44,
                          height: 2.5,
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
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                                width: 1.3,
                              ),
                            ),
                            child: const Icon(
                              Icons.settings_outlined,
                              color: Colors.white,
                              size: 21,
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

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: () => _pickImage(ImageSource.camera),
      child: Container(
        width: double.infinity,
        height: 115,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.28),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // Camera icon in frosted circle
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Scan Fish Now',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'AI-powered freshness analysis',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Arrow indicator
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 14,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade100),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.teal, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: const Color(0xFF1A5694),
              ),
            ),
          ],
        ),
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
