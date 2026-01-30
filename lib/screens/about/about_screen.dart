import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF05111A), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomHeader(context),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroBrand(),

                      const SizedBox(height: 40),
                      _buildSectionLabel("SYSTEM METRICS"),
                      _buildBentoGrid(),

                      const SizedBox(height: 35),
                      _buildSectionLabel("ANALYSIS LOGIC"),
                      _buildProcessTimeline(),

                      const SizedBox(height: 35),
                      _buildSectionLabel("QUALITY STANDARDS"),
                      _buildFreshnessCards(),

                      const SizedBox(height: 35),
                      _buildSectionLabel("SUPPORT CHANNEL"),
                      _buildContactTile(),

                      const SizedBox(height: 50),
                      _buildFooter(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.cyanAccent,
              ),
            ),
          ),
          // Screen Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Text(
              "SYSTEM_INFO",
              style: GoogleFonts.coda(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              "FINALYZE",
              style: GoogleFonts.lexend(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "AI-Powered Freshness Detection Engine\nv1.0.0 (Stable Build)",
          style: GoogleFonts.poppins(
            color: Colors.white38,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBentoGrid() {
    return Column(
      children: [
        // Top Row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildMetricCard(
                Icons.bolt_rounded,
                "Latency",
                "0.5s",
                Colors.amberAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: _buildMetricCard(
                Icons.verified_user_outlined,
                "Accuracy",
                "99.4%",
                Colors.cyanAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Bottom Row
        _buildFullMetricCard(
          Icons.security,
          "Data Privacy",
          "End-to-End Encrypted",
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    IconData icon,
    String label,
    String value,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 24),
          const SizedBox(height: 15),
          Text(
            value,
            style: GoogleFonts.lexend(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFullMetricCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purpleAccent, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
              ),
              Text(
                value,
                style: GoogleFonts.lexend(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessTimeline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(color: Colors.cyanAccent.withOpacity(0.5), width: 2),
        ),
      ),
      child: Column(
        children: [
          _buildTimelineItem("1", "Input", "High-res capture of gills/eyes."),
          const SizedBox(height: 20),
          _buildTimelineItem(
            "2",
            "Processing",
            "CNN Feature Extraction & Pattern Matching.",
          ),
          const SizedBox(height: 20),
          _buildTimelineItem(
            "3",
            "Output",
            "Freshness Score & Culinary Recommendation.",
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String step, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step,
          style: GoogleFonts.coda(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lexend(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFreshnessCards() {
    return Column(
      children: [
        _buildStatusRow(
          "FRESH (Grade A)",
          "Safe for raw consumption",
          Colors.greenAccent,
        ),
        const SizedBox(height: 10),
        _buildStatusRow(
          "MODERATE (Grade B)",
          "Cook thoroughly",
          Colors.amberAccent,
        ),
        const SizedBox(height: 10),
        _buildStatusRow("POOR (Grade C)", "Do not consume", Colors.redAccent),
      ],
    );
  }

  Widget _buildStatusRow(String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.4), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyanAccent.withOpacity(0.05), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "support@finalyze.ai",
                style: GoogleFonts.lexend(color: Colors.white, fontSize: 16),
              ),
              Text(
                "Karachi, Pakistan",
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          Icon(Icons.arrow_outward, color: Colors.cyanAccent.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        text,
        style: GoogleFonts.coda(
          color: Colors.cyanAccent.withOpacity(0.7),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        "© 2026 Finalyze Inc. All Rights Reserved.",
        style: GoogleFonts.poppins(color: Colors.white24, fontSize: 10),
      ),
    );
  }
}
