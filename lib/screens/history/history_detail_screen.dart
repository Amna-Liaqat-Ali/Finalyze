import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/api_config.dart';
import '../../widgets/app_inner_bar.dart';
import 'history_screen.dart';

class HistoryDetailScreen extends StatelessWidget {
  final ScanHistory item;

  const HistoryDetailScreen({super.key, required this.item});

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

  String get _statusLabel => item.status.name[0].toUpperCase() + item.status.name.substring(1);

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

  Widget _buildImage() {
    final placeholder = Container(
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),
    );
    if (item.image.isEmpty) return placeholder;

    if (item.image.startsWith('http') || item.image.startsWith('uploads/')) {
      final serverBase = ApiConfig.baseUrl.replaceAll('/api', '');
      final url = item.image.startsWith('http')
          ? item.image
          : '$serverBase/${item.image.replaceAll(r'\', '/')}';
      return Image.network(url, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder);
    }

    try {
      final data = item.image.contains(',') ? item.image.split(',').last : item.image;
      final bytes = base64Decode(data);
      return Image.memory(bytes, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder);
    } catch (_) {
      return placeholder;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A5694);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppInnerBar(
        title: "Full Report",
        onBack: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Hero image
            SizedBox(
              height: 260,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(),
                  // Bottom gradient
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
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge + confidence
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: _statusColor.withOpacity(0.3)),
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
                        child: Text("confidence",
                          style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Species title
                  Text(
                    item.fishName,
                    style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold, color: primaryBlue,
                    ),
                  ),
                  Text(
                    item.source,
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 20),

                  // Confidence progress bar
                  _buildConfidenceBar(),
                  const SizedBox(height: 20),

                  // Info card
                  _buildInfoCard(primaryBlue),
                  const SizedBox(height: 16),

                  // Recommendation card
                  _buildRecommendation(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("AI Confidence",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.blueGrey)),
            const Spacer(),
            Text("${item.confidence}%",
              style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.bold, color: _statusColor)),
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
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _infoRow(Icons.set_meal_rounded, "Species", item.fishName, primaryBlue),
          _divider(),
          _infoRow(Icons.location_on_rounded, "Source / Area", item.source, primaryBlue),
          _divider(),
          _infoRow(Icons.calendar_today_rounded, "Date",
              DateFormat('MMMM d, yyyy').format(item.dateTime), primaryBlue),
          _divider(),
          _infoRow(Icons.access_time_rounded, "Time",
              DateFormat('hh:mm a').format(item.dateTime), primaryBlue),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: primary.withOpacity(0.5), size: 18),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
          const Spacer(),
          Text(value,
            style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w600, color: primary)),
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
                    fontWeight: FontWeight.bold, color: _statusColor, fontSize: 14)),
                const SizedBox(height: 4),
                Text(_recommendation,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.blueGrey, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
