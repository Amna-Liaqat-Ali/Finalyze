import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_sizes.dart';
import '../../core/scan_limit_service.dart';
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
          icon: Icon(Icons.close_rounded, color: Colors.white, size: rs(context, 22)),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          tooltip: 'Cancel',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(rs(context, 20), rsh(context, 20), rs(context, 20), 0),
              child: Column(
                children: [
                  // Image preview
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(rs(context, 22)),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(rs(context, 22)),
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
                            : Center(
                                child: Icon(Icons.image_not_supported_rounded,
                                    size: rs(context, 60), color: Colors.grey),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: rsh(context, 16)),
                  _buildTip(context),
                  SizedBox(height: rsh(context, 20)),
                ],
              ),
            ),
          ),
          _buildActionBar(context),
        ],
      ),
    );
  }

  Widget _buildTip(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rsh(context, 12)),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF6FF),
        borderRadius: BorderRadius.circular(rs(context, 14)),
        border: Border.all(color: const Color(0xFF1A5694).withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Icon(Icons.tips_and_updates_rounded,
              color: const Color(0xFF2CB88E), size: rs(context, 18)),
          SizedBox(width: rs(context, 10)),
          Expanded(
            child: Text(
              "For best results, center the fish eye or gills and ensure good lighting.",
              style: GoogleFonts.poppins(
                color: const Color(0xFF1A5694),
                fontSize: rs(context, 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(rs(context, 20), rsh(context, 14), rs(context, 20), rsh(context, 32)),
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
                icon: Icon(Icons.refresh_rounded, size: rs(context, 17)),
                label: Text(
                  "Retake",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: rs(context, 14)),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A5694),
                  side: const BorderSide(color: Color(0xFFDDE3ED), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(rs(context, 14)),
                  ),
                  padding: EdgeInsets.symmetric(vertical: rsh(context, 14)),
                ),
              ),
            ),
            SizedBox(width: rs(context, 14)),
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: image == null
                    ? null
                    : () async {
                        final status = await ScanLimitService.getStatus();
                        if (status.isLimited) {
                          if (!context.mounted) return;
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => _ScanLimitSheet(resetAt: status.resetAt!),
                          );
                          return;
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
                  height: rsh(context, 50),
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
                    borderRadius: BorderRadius.circular(rs(context, 14)),
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
                      Icon(Icons.biotech_rounded,
                          color: Colors.white, size: rs(context, 19)),
                      SizedBox(width: rs(context, 8)),
                      Text(
                        "Analyze",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: rs(context, 15),
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
      padding: EdgeInsets.fromLTRB(rs(context, 24), rsh(context, 16), rs(context, 24), rsh(context, 40)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: rs(context, 40), height: rsh(context, 4),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade200,
              borderRadius: BorderRadius.circular(rs(context, 4)),
            ),
          ),
          SizedBox(height: rsh(context, 28)),
          Container(
            padding: EdgeInsets.all(rs(context, 20)),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_clock_rounded,
                color: Colors.orange, size: rs(context, 48)),
          ),
          SizedBox(height: rsh(context, 20)),
          Text("Daily Limit Reached",
              style: GoogleFonts.poppins(
                  fontSize: rs(context, 20),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D2E5C))),
          SizedBox(height: rsh(context, 8)),
          Text(
            "You've used all 15 free scans for today.\nScanner resets in:",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: rs(context, 13), color: Colors.blueGrey, height: 1.6),
          ),
          SizedBox(height: rsh(context, 24)),
          // Countdown timer
          Container(
            padding: EdgeInsets.symmetric(horizontal: rs(context, 32), vertical: rsh(context, 16)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D2E5C), Color(0xFF1A5694), Color(0xFF0891B2)],
              ),
              borderRadius: BorderRadius.circular(rs(context, 16)),
            ),
            child: Text(
              "$h : $m : $s",
              style: GoogleFonts.poppins(
                  fontSize: rs(context, 32),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4),
            ),
          ),
          SizedBox(height: rsh(context, 28)),
          // Upgrade button
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              PremiumScreen.showAsSheet(context);
            },
            child: Container(
              width: double.infinity,
              height: rsh(context, 54),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D2E5C), Color(0xFF1A5694), Color(0xFF0891B2)],
                ),
                borderRadius: BorderRadius.circular(rs(context, 14)),
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
                        fontSize: rs(context, 15))),
              ),
            ),
          ),
          SizedBox(height: rsh(context, 12)),
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
