import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Main/analyzing_screen.dart';
import '../premium/premium_screen.dart';

class ReviewScreen extends StatelessWidget {
  final File? image;
  const ReviewScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D2E5C), Color(0xFF1A5694), Color(0xFF0891B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          tooltip: 'Cancel',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  // Image preview 
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: image != null
                            ? Image.file(image!, fit: BoxFit.cover)
                            : const Center(
                                child: Icon(Icons.image_not_supported_rounded,
                                    size: 60, color: Colors.grey),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTip(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildActionBar(context),
        ],
      ),
    );
  }

  Widget _buildTip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A5694).withOpacity(0.10)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates_rounded,
              color: Color(0xFF2CB88E), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "For best results, center the fish eye or gills and ensure good lighting.",
              style: GoogleFonts.poppins(
                color: const Color(0xFF1A5694),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Retake
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: () {
                  final nav = Navigator.of(context);
                  nav.pop(); // pop ReviewScreen
                  nav.pop(); // pop back to ScanScreen
                },
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: Text(
                  "Retake",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A5694),
                  side: const BorderSide(color: Color(0xFFDDE3ED), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: image == null
                    ? null
                    : () async {
                        final prefs = await SharedPreferences.getInstance();
                        final now = DateTime.now();

                        // Only enforce limit for logged-in users
                        final isPremium = prefs.getBool('is_premium') ?? false;
                        if (!isPremium) {
                          const countKey = 'scan_count';
                          const windowKey = 'scan_window_start';

                          final windowStart = prefs.getString(windowKey);
                          DateTime? windowTime = windowStart != null
                              ? DateTime.tryParse(windowStart)
                              : null;

                          if (windowTime == null ||
                              now.difference(windowTime).inHours >= 24) {
                            windowTime = now;
                            await prefs.setString(windowKey, now.toIso8601String());
                            await prefs.setInt(countKey, 0);
                          }

                          final count = prefs.getInt(countKey) ?? 0;

                          if (count >= 15) {
                            final resetAt = windowTime!.add(const Duration(hours: 24));
                            if (!context.mounted) return;
                            await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => _ScanLimitSheet(resetAt: resetAt),
                            );
                            return;
                          }

                          await prefs.setInt(countKey, count + 1);
                        }
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnalyzingScreen(image: image!),
                          ),
                        );
                      },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: image == null
                          ? [Colors.grey.shade300, Colors.grey.shade400]
                          : const [
                              Color(0xFF0D2E5C),
                              Color(0xFF1565C0),
                              Color(0xFF0891B2),
                              Color(0xFF2CB88E),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: image == null
                        ? []
                        : [
                            BoxShadow(
                              color: const Color(0xFF1565C0).withOpacity(0.30),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.biotech_rounded,
                          color: Colors.white, size: 19),
                      const SizedBox(width: 8),
                      Text(
                        "Analyze",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanLimitSheet extends StatefulWidget {
  final DateTime resetAt;
  const _ScanLimitSheet({required this.resetAt});

  @override
  State<_ScanLimitSheet> createState() => _ScanLimitSheetState();
}

class _ScanLimitSheetState extends State<_ScanLimitSheet> {
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
    if (mounted) setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
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

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_clock_rounded,
                color: Colors.orange, size: 48),
          ),
          const SizedBox(height: 20),
          Text("Daily Limit Reached",
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D2E5C))),
          const SizedBox(height: 8),
          Text(
            "You've used all 15 free scans for today.\nScanner resets in:",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.blueGrey, height: 1.6),
          ),
          const SizedBox(height: 24),
          // Countdown timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D2E5C), Color(0xFF1A5694), Color(0xFF0891B2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              "$h : $m : $s",
              style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4),
            ),
          ),
          const SizedBox(height: 28),
          // Upgrade button
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              PremiumScreen.showAsSheet(context);
            },
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D2E5C), Color(0xFF1A5694), Color(0xFF0891B2)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0891B2).withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text("Upgrade to Premium",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Wait for Reset",
                style: GoogleFonts.poppins(
                    color: Colors.blueGrey, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
