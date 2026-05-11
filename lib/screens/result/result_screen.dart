import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../cook/recipe_screen.dart';

class ResultScreen extends StatelessWidget {
  final File image;
  final double freshnessScore;
  final double confidence;
  final String status;
  final String species;
  final String scanArea;

  const ResultScreen({
    super.key,
    required this.image,
    required this.freshnessScore,
    required this.confidence,
    required this.status,
    this.species = "Detected Fish",
    this.scanArea = "Eye & Gills",
  });

  @override
  Widget build(BuildContext context) {
    final bool isFresh = status.toLowerCase() == 'fresh';
    final bool isModerate = status.toLowerCase() == 'moderate';

    final Color primaryBlue = const Color(0xFF1A5694);
    final Color statusColor = isFresh
        ? const Color(0xFF2CB88E)
        : (isModerate ? Colors.orange : Colors.redAccent);

    final String advisoryText = isFresh
        ? "Optimal for consumption. Store at 0-2°C in a sealed container."
        : (isModerate
              ? "Signs of degradation detected. Use immediately for cooked dishes only."
              : "Spoilage detected. Not safe for consumption. Please discard.");

    final String scanDate = DateFormat('MMM dd, yyyy').format(DateTime.now());
    final String scanTime = DateFormat('hh:mm a').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              icon: Icon(Icons.refresh, size: 20, color: primaryBlue),
              label: Text(
                "Rescan",
                style: GoogleFonts.poppins(
                  color: primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.file(image, fit: BoxFit.cover),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScanDetails(scanDate, scanTime, scanArea, primaryBlue),

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
                        status.toUpperCase(),
                        statusColor.withOpacity(0.12),
                        statusColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "$status State",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Our AI model analyzed the visual markers. The biological data indicates a $status freshness level with ${confidence.toStringAsFixed(1)}% confidence.",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.blueGrey.shade600,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      _buildMetricCard(
                        "Freshness",
                        "${freshnessScore.toInt()}%",
                        statusColor,
                      ),
                      const SizedBox(width: 16),
                      _buildMetricCard(
                        "Confidence",
                        "${confidence.toInt()}%",
                        primaryBlue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Text(
                    "Storage Advisory",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blueGrey.shade50),
                    ),
                    child: Text(
                      advisoryText,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.blueGrey.shade800,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          label: "SAVE REPORT",
                          icon: Icons.assignment_turned_in_outlined,
                          color: primaryBlue,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Report saved to history"),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _actionButton(
                          label: "VIEW RECIPES",
                          icon: Icons.restaurant_menu_rounded,
                          color: const Color(0xFF2CB88E),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RecipeScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                      child: Text(
                        "DISMISS",
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
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
    );
  }

  Widget _buildScanDetails(String date, String time, String area, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _infoColumn("DATE", date, color),
          _infoColumn("TIME", time, color),
          _infoColumn("AREA", area, color),
        ],
      ),
    );
  }

  Widget _infoColumn(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.blueGrey.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
