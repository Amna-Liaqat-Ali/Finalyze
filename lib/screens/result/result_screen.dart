import 'dart:io';
import 'dart:ui'; // Required for ImageFilter

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cook/recipe_screen.dart';

class ResultScreen extends StatelessWidget {
  final File? image;
  final double freshnessScore;
  final double confidence;
  final String status;

  const ResultScreen({
    super.key,
    this.image,
    this.freshnessScore = 95.0,
    this.confidence = 98.0,
    this.status = "Fresh",
  });

  Color get statusColor {
    if (freshnessScore > 80) return const Color(0xFF00E676); // Neon Green
    if (freshnessScore > 50) return const Color(0xFFFFAB00); // Amber
    return const Color(0xFFFF1744); // Neon Red
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2B45), // Deep Navy Base
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Analysis Result",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF0D2B45), const Color(0xFF102030)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  _buildFuturisticGauge(),

                  const SizedBox(height: 40),

                  _buildGlassPill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DETECTED SPECIES",
                              style: GoogleFonts.oswald(
                                color: Colors.white38,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Red Snapper",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusColor.withOpacity(0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: GoogleFonts.oswald(
                              color: statusColor,
                              fontSize: 14,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassTile(
                          Icons.analytics_outlined,
                          "Confidence",
                          "${confidence.toInt()}%",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGlassTile(
                          Icons.access_time_filled_outlined,
                          "Est. Age",
                          "< 24h",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildGlassTile(
                    Icons.location_on_outlined,
                    "Origin Source",
                    "Karachi Fish Harbor, Dock 4",
                    isWide: true,
                  ),

                  const SizedBox(height: 30),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "AI RECOMMENDATIONS",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRecItem("Perfect for raw dishes (Sushi/Sashimi)"),
                  _buildRecItem("Keep refrigerated at 0-4°C"),
                  _buildRecItem("Consume within 24 hours for best taste"),

                  const SizedBox(height: 40),

                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00B4D8).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.restaurant_menu,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "View Recipes",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuturisticGauge() {
    return SizedBox(
      height: 200,
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Track Ring
          SizedBox(
            height: 200,
            width: 200,
            child: CircularProgressIndicator(
              value: 0.75,
              strokeWidth: 2,
              color: Colors.white.withOpacity(0.1),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Value Ring
          SizedBox(
            height: 200,
            width: 200,
            child: CircularProgressIndicator(
              value: (freshnessScore / 100) * 0.75,
              strokeWidth: 8,
              color: statusColor,
              backgroundColor: Colors.transparent,
              strokeCap: StrokeCap.round,
            ),
          ),
          // Text Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${freshnessScore.toInt()}",
                style: GoogleFonts.bebasNeue(
                  fontSize: 80,
                  color: Colors.white,
                  height: 1,
                  shadows: [
                    Shadow(color: statusColor.withOpacity(0.6), blurRadius: 20),
                  ],
                ),
              ),
              Text(
                "FRESHNESS SCORE",
                style: GoogleFonts.oswald(
                  fontSize: 12,
                  color: statusColor,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassPill({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassTile(
    IconData icon,
    String label,
    String value, {
    bool isWide = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF142A40),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: isWide
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF00B4D8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF00B4D8), size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.oswald(
                  color: Colors.white38,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
