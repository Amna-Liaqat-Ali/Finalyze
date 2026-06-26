import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'history_screen.dart';
import 'services/scan_service.dart';

class HistoryDetailScreen extends StatefulWidget {
  final ScanHistory item;

  const HistoryDetailScreen({super.key, required this.item});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  late Future<File?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = item.id.isEmpty
        ? Future.value(null)
        : ScanService.getScanImageFile(item.id);
  }

  ScanHistory get item => widget.item;

  Color get _statusColor {
    switch (item.status) {
      case ScanStatus.fresh:
        return const Color(0xFF2CB88E);
      case ScanStatus.fair:
        return const Color(0xFF1E88E5);
      case ScanStatus.moderate:
        return Colors.orange;
      case ScanStatus.spoiled:
        return Colors.redAccent;
    }
  }

  String get _statusLabel =>
      item.status.name[0].toUpperCase() + item.status.name.substring(1);

  String get _speciesOrigin {
    final key = item.fishName.toLowerCase();
    if (key.contains('pomfret') || key.contains('paplet')) return 'Arabian Sea, Karachi';
    if (key.contains('surmai') || key.contains('kingfish')) return 'Arabian Sea, Offshore';
    return 'Pakistani Waters';
  }

  String get _speciesDescription {
    final key = item.fishName.toLowerCase();
    if (key.contains('pomfret') || key.contains('paplet')) {
      return 'Pomfret (Paplet) is a silver-bodied coastal fish widely found in the Arabian Sea. It is highly prized in Pakistani markets for its delicate white flesh and mild flavour, making it ideal for frying, grilling, and curries.';
    }
    if (key.contains('surmai') || key.contains('kingfish')) {
      return 'Kingfish (Surmai) is a premium deep-sea migratory fish found along Pakistan\'s coastline. Known for its dense, flavourful flesh and high omega-3 content, it is one of the most commercially valuable fish in Karachi markets.';
    }
    return 'A fish species detected by the Finalyze AI model from a scan of its biological markers.';
  }

  int get _freshnessPercent {
    final conf = item.confidence / 100;
    switch (item.status) {
      case ScanStatus.fresh: return (85 + conf * 15).toInt().clamp(0, 100);
      case ScanStatus.fair: return (55 + conf * 20).toInt().clamp(0, 100);
      case ScanStatus.moderate: return (40 + conf * 30).toInt().clamp(0, 100);
      case ScanStatus.spoiled: return (conf * 35).toInt().clamp(0, 100);
    }
  }

  String get _recommendation {
    switch (item.status) {
      case ScanStatus.fresh:
        return "Excellent quality! Safe for immediate consumption, cooking, or storage up to 2 days.";
      case ScanStatus.fair:
        return "Good quality. Cook immediately for best results. Do not store raw.";
      case ScanStatus.moderate:
        return "Borderline freshness. Cook thoroughly at high heat. Not suitable for raw consumption.";
      case ScanStatus.spoiled:
        return "Not safe for consumption. Discard immediately to avoid health risks.";
    }
  }

  IconData get _statusIcon {
    switch (item.status) {
      case ScanStatus.fresh:
        return Icons.check_circle_rounded;
      case ScanStatus.fair:
        return Icons.info_rounded;
      case ScanStatus.moderate:
        return Icons.warning_amber_rounded;
      case ScanStatus.spoiled:
        return Icons.cancel_rounded;
    }
  }

  Widget _buildImageArea() {
    final placeholder = Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 48),
      ),
    );

    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder<File?>(
            future: _imageFuture,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Container(
                  color: const Color(0xFFEEF4FF),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0891B2),
                    ),
                  ),
                );
              }
              if (snap.hasData && snap.data != null) {
                return Image.file(snap.data!, fit: BoxFit.cover, gaplessPlayback: true);
              }
              return placeholder;
            },
          ),
          // Bottom fade
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xFFF8FAFC), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A5694);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildImageArea(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: _statusColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_statusIcon, color: _statusColor, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              _statusLabel,
                              style: GoogleFonts.poppins(
                                color: _statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${item.confidence}%",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _statusColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          "confidence",
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    item.fishName,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _speciesDescription,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.blueGrey.shade500,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildFreshnessBar(),
                  const SizedBox(height: 12),
                  _buildConfidenceBar(),
                  const SizedBox(height: 20),

                  _buildInfoCard(primaryBlue),
                  const SizedBox(height: 16),

                  _buildRecommendation(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreshnessBar() {
    final percent = _freshnessPercent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Freshness Level",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.blueGrey)),
            Text("$percent%",
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.bold, color: _statusColor)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
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

  Widget _buildConfidenceBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Confidence Score",
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.blueGrey)),
            const Spacer(),
            Text("${item.confidence}%",
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _statusColor)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: item.confidence / 100,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(Color primaryBlue) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _infoRow(Icons.set_meal_rounded, "Species", item.fishName,
              primaryBlue),
          _divider(),
          _infoRow(
            Icons.calendar_today_rounded,
            "Date",
            DateFormat('MMMM d, yyyy').format(item.dateTime),
            primaryBlue,
          ),
          _divider(),
          _infoRow(
            Icons.location_on_rounded,
            "Origin",
            _speciesOrigin,
            primaryBlue,
          ),
          _divider(),
          _infoRow(
            Icons.access_time_rounded,
            "Time",
            DateFormat('hh:mm a').format(item.dateTime),
            primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      IconData icon, String label, String value, Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: primary.withOpacity(0.5), size: 18),
          const SizedBox(width: 12),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: Colors.grey)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primary)),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.grey.shade100, height: 1);

  Widget _buildRecommendation() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_statusIcon, color: _statusColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Recommendation",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: _statusColor,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(_recommendation,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.blueGrey,
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
