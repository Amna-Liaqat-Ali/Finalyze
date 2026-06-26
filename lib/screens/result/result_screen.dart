import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/app_sizes.dart';
import '../../core/user_session.dart';
import '../cook/recipe_screen.dart';
import '../history/services/scan_service.dart';

enum _SaveStatus { saving, saved, failed, skipped }

class ResultScreen extends StatefulWidget {
  final File image;
  final String detectedLabel;
  final double confidence;
  final String scanArea;
  final VoidCallback? onSaved;

  const ResultScreen({
    super.key,
    required this.image,
    required this.detectedLabel,
    required this.confidence,
    this.scanArea = "Eye & Gills",
    this.onSaved,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  _SaveStatus _saveStatus = _SaveStatus.saving;

  @override
  void initState() {
    super.initState();
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    if (!UserSession.isLoggedIn) {
      if (mounted) setState(() => _saveStatus = _SaveStatus.skipped);
      return;
    }

    final saved = await ScanService.saveScanFromAnalysis(
      imageFile: widget.image,
      detectedLabel: widget.detectedLabel,
      confidence: widget.confidence,
      scanArea: widget.scanArea,
    );

    if (!mounted) return;

    setState(() => _saveStatus = saved ? _SaveStatus.saved : _SaveStatus.failed);

    if (saved) {
      widget.onSaved?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.detectedLabel == "data_invalid" || widget.confidence < 0.4) {
      return _buildInvalidScanUI(context);
    }

    List<String> parts = widget.detectedLabel.split('_');
    final speciesKey = parts.isNotEmpty ? parts[0].toLowerCase() : 'unknown';
    String status = parts.length > 1 ? parts[1].toUpperCase() : "UNKNOWN";

    const speciesNames = {
      'pomfret': 'Pomfret (Paplet)',
      'surmai': 'Kingfish (Surmai)',
    };
    const speciesDescriptions = {
      'pomfret': 'Pomfret (Paplet) is a silver-bodied marine fish widely consumed across Pakistan. It is highly valued for its delicate, white flesh.',
      'surmai': 'Kingfish (Surmai) is a premium deep-sea fish prized in Karachi markets for its dense, flavourful flesh and high omega-3 content.',
    };

    final String species = speciesNames[speciesKey] ?? speciesKey.toUpperCase();
    final String speciesDesc = speciesDescriptions[speciesKey] ?? 'Fish species detected by AI model.';

    final bool isFresh = status.toLowerCase() == 'fresh';
    final bool isModerate = status.toLowerCase() == 'moderate';

    const Color primaryBlue = Color(0xFF1A5694);
    final Color statusColor = isFresh
        ? const Color(0xFF2CB88E)
        : (isModerate ? Colors.orange : Colors.redAccent);

    final String scanDate = DateFormat('MMM dd, yyyy').format(DateTime.now());
    final String scanTime = DateFormat('hh:mm a').format(DateTime.now());

    // Freshness % based on status range + confidence
    final double freshnessScore = isFresh
        ? (0.75 + widget.confidence * 0.25) * 100
        : isModerate
            ? (0.35 + widget.confidence * 0.25) * 100
            : (widget.confidence * 0.20) * 100;
    final int freshnessPercent = freshnessScore.clamp(0, 100).toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, primaryBlue),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildImageHeader(context),
            Padding(
              padding: EdgeInsets.all(rs(context, 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScanDetails(scanDate, scanTime, widget.scanArea, primaryBlue),
                  const SizedBox(height: 20),
                  _buildSaveStatusBanner(primaryBlue),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildChip(
                        species,
                        primaryBlue.withOpacity(0.08),
                        primaryBlue,
                      ),
                      const SizedBox(width: 10),
                      _buildChip(
                        status,
                        statusColor.withOpacity(0.12),
                        statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    species,
                    style: GoogleFonts.poppins(
                      fontSize: rs(context, 24),
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  SizedBox(height: rsh(context, 6)),
                  Text(
                    speciesDesc,
                    style: GoogleFonts.poppins(
                      fontSize: rs(context, 12),
                      color: Colors.blueGrey.shade500,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: rsh(context, 8)),
                  Text(
                    "Biological markers in the ${widget.scanArea} indicate a ${status.toLowerCase()} freshness state with ${(widget.confidence * 100).toStringAsFixed(1)}% AI confidence.",
                    style: GoogleFonts.poppins(
                      fontSize: rs(context, 13),
                      color: Colors.blueGrey.shade600,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _buildMetricCard(
                        "Freshness",
                        "$freshnessPercent%",
                        statusColor,
                      ),
                      const SizedBox(width: 16),
                      _buildMetricCard(
                        "AI Confidence",
                        "${(widget.confidence * 100).toInt()}%",
                        primaryBlue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFreshnessBar(context, freshnessPercent, statusColor),
                  const SizedBox(height: 40),
                  _buildActionRow(context, primaryBlue),
                  _buildDismissButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveStatusBanner(Color primaryBlue) {
    late final Color bgColor;
    late final Color borderColor;
    late final Color iconColor;
    late final IconData icon;
    late final String message;

    switch (_saveStatus) {
      case _SaveStatus.saving:
        bgColor = primaryBlue.withOpacity(0.08);
        borderColor = primaryBlue.withOpacity(0.2);
        iconColor = primaryBlue;
        icon = Icons.cloud_upload_rounded;
        message = "Saving scan to your history...";
      case _SaveStatus.saved:
        bgColor = const Color(0xFF2CB88E).withOpacity(0.08);
        borderColor = const Color(0xFF2CB88E).withOpacity(0.2);
        iconColor = const Color(0xFF2CB88E);
        icon = Icons.cloud_done_rounded;
        message = "Scan saved to your history.";
      case _SaveStatus.failed:
        bgColor = Colors.redAccent.withOpacity(0.08);
        borderColor = Colors.redAccent.withOpacity(0.2);
        iconColor = Colors.redAccent;
        icon = Icons.cloud_off_rounded;
        message = "Could not save to history. Check your connection.";
      case _SaveStatus.skipped:
        bgColor = Colors.orange.withOpacity(0.08);
        borderColor = Colors.orange.withOpacity(0.2);
        iconColor = Colors.orange;
        icon = Icons.info_outline_rounded;
        message = "Log in to save scans to your history.";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          if (_saveStatus == _SaveStatus.saving)
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: iconColor,
              ),
            )
          else
            Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: primaryBlue,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvalidScanUI(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(40),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.no_photography_outlined,
                size: 80,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Invalid Object!",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A5694),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "We couldn't identify a fish in this image. Please take a clear photo focusing on the eyes and gills.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.blueGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A5694),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "TRY AGAIN",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Color primaryBlue) {
    return AppBar(
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
        tooltip: 'Close',
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: rs(context, 16)),
      height: rsh(context, 200),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: DecorationImage(
          image: FileImage(widget.image),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildScanDetails(String date, String time, String area, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _infoColumn("DATE", date, color),
        _infoColumn("TIME", time, color),
      ],
    );
  }

  Widget _infoColumn(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Expanded(
      child: Builder(builder: (context) => Container(
        padding: EdgeInsets.all(rs(context, 16)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: rs(context, 24),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: rs(context, 11), color: Colors.blueGrey),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildFreshnessBar(BuildContext context, int percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Freshness Level",
              style: GoogleFonts.poppins(
                fontSize: rs(context, 13),
                color: Colors.blueGrey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "$percent%",
              style: GoogleFonts.poppins(
                fontSize: rs(context, 13),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 10,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Spoiled", style: GoogleFonts.poppins(fontSize: 10, color: Colors.red.shade300)),
            Text("Moderate", style: GoogleFonts.poppins(fontSize: 10, color: Colors.orange.shade300)),
            Text("Fresh", style: GoogleFonts.poppins(fontSize: 10, color: Colors.green.shade400)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionRow(BuildContext context, Color primaryBlue) {
    final statusKey = widget.detectedLabel.split('_').length > 1
        ? widget.detectedLabel.split('_')[1].toLowerCase()
        : 'fresh';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => RecipeScreen(freshnessStatus: statusKey)),
      ),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D2E5C), Color(0xFF1A5694), Color(0xFF0891B2), Color(0xFF2CB88E)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0891B2).withOpacity(0.30),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              "View Recipes",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        child: Text(
          "Done",
          style: GoogleFonts.poppins(
            color: Colors.blueGrey,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
