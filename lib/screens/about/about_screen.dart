import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_sizes.dart';
import '../../widgets/app_back_button.dart';

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
                  padding: EdgeInsets.symmetric(horizontal: rs(context, 24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroBrand(context),

                      SizedBox(height: rsh(context, 40)),
                      _buildSectionLabel(context, "SYSTEM METRICS"),
                      _buildBentoGrid(context),

                      SizedBox(height: rsh(context, 35)),
                      _buildSectionLabel(context, "ANALYSIS LOGIC"),
                      _buildProcessTimeline(context),

                      SizedBox(height: rsh(context, 35)),
                      _buildSectionLabel(context, "QUALITY STANDARDS"),
                      _buildFreshnessCards(context),

                      SizedBox(height: rsh(context, 35)),
                      _buildSectionLabel(context, "SUPPORT CHANNEL"),
                      _buildContactTile(context),

                      SizedBox(height: rsh(context, 50)),
                      _buildFooter(context),
                      SizedBox(height: rsh(context, 20)),
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
      padding: EdgeInsets.symmetric(horizontal: rs(context, 20), vertical: rsh(context, 20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppBackButton(isGlass: true, onTap: () => Navigator.pop(context)),
          // Screen Title
          Container(
            padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rsh(context, 8)),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(rs(context, 20)),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Text(
              "SYSTEM_INFO",
              style: GoogleFonts.coda(
                color: Colors.white54,
                fontSize: rs(context, 12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBrand(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: rsh(context, 10)),
        Row(
          children: [
            Text(
              "FINALYZE",
              style: GoogleFonts.lexend(
                fontSize: rs(context, 32),
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: rsh(context, 8)),
        Text(
          "AI-Powered Freshness Detection Engine\nv1.0.0 (Stable Build)",
          style: GoogleFonts.poppins(
            color: Colors.white38,
            fontSize: rs(context, 13),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBentoGrid(BuildContext context) {
    return Column(
      children: [
        // Top Row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildMetricCard(
                context,
                Icons.bolt_rounded,
                "Latency",
                "0.5s",
                Colors.amberAccent,
              ),
            ),
            SizedBox(width: rs(context, 12)),
            Expanded(
              flex: 3,
              child: _buildMetricCard(
                context,
                Icons.verified_user_outlined,
                "Accuracy",
                "99.4%",
                Colors.cyanAccent,
              ),
            ),
          ],
        ),
        SizedBox(height: rsh(context, 12)),
        // Bottom Row
        _buildFullMetricCard(
          context,
          Icons.security,
          "Data Privacy",
          "End-to-End Encrypted",
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color accent,
  ) {
    return Container(
      padding: EdgeInsets.all(rs(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(rs(context, 20)),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: rs(context, 24)),
          SizedBox(height: rsh(context, 15)),
          Text(
            value,
            style: GoogleFonts.lexend(
              color: Colors.white,
              fontSize: rs(context, 22),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: rs(context, 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildFullMetricCard(BuildContext context, IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(rs(context, 20)),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(rs(context, 20)),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purpleAccent, size: rs(context, 24)),
          SizedBox(width: rs(context, 15)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: rs(context, 12)),
              ),
              Text(
                value,
                style: GoogleFonts.lexend(
                  color: Colors.white,
                  fontSize: rs(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessTimeline(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 20), vertical: rsh(context, 25)),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A).withOpacity(0.3),
        borderRadius: BorderRadius.circular(rs(context, 20)),
        border: Border(
          left: BorderSide(color: Colors.cyanAccent.withOpacity(0.5), width: 2),
        ),
      ),
      child: Column(
        children: [
          _buildTimelineItem(context, "1", "Input", "High-res capture of gills/eyes."),
          SizedBox(height: rsh(context, 20)),
          _buildTimelineItem(
            context,
            "2",
            "Processing",
            "CNN Feature Extraction & Pattern Matching.",
          ),
          SizedBox(height: rsh(context, 20)),
          _buildTimelineItem(
            context,
            "3",
            "Output",
            "Freshness Score & Culinary Recommendation.",
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, String step, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step,
          style: GoogleFonts.coda(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            fontSize: rs(context, 14),
          ),
        ),
        SizedBox(width: rs(context, 15)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lexend(color: Colors.white, fontSize: rs(context, 14)),
              ),
              SizedBox(height: rsh(context, 2)),
              Text(
                desc,
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: rs(context, 12)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFreshnessCards(BuildContext context) {
    return Column(
      children: [
        _buildStatusRow(
          context,
          "FRESH (Grade A)",
          "Safe for raw consumption",
          Colors.greenAccent,
        ),
        SizedBox(height: rsh(context, 10)),
        _buildStatusRow(
          context,
          "MODERATE (Grade B)",
          "Cook thoroughly",
          Colors.amberAccent,
        ),
        SizedBox(height: rsh(context, 10)),
        _buildStatusRow(context, "POOR (Grade C)", "Do not consume", Colors.redAccent),
      ],
    );
  }

  Widget _buildStatusRow(BuildContext context, String title, String desc, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 20), vertical: rsh(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(rs(context, 16)),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            height: rs(context, 10),
            width: rs(context, 10),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.4), blurRadius: 8),
              ],
            ),
          ),
          SizedBox(width: rs(context, 15)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    color: Colors.white,
                    fontSize: rs(context, 13),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: rs(context, 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(rs(context, 24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyanAccent.withOpacity(0.05), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(rs(context, 20)),
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
                style: GoogleFonts.lexend(color: Colors.white, fontSize: rs(context, 16)),
              ),
              Text(
                "Karachi, Pakistan",
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: rs(context, 12)),
              ),
            ],
          ),
          Icon(Icons.arrow_outward, color: Colors.cyanAccent.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: rsh(context, 15)),
      child: Text(
        text,
        style: GoogleFonts.coda(
          color: Colors.cyanAccent.withOpacity(0.7),
          fontSize: rs(context, 11),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Text(
        "© 2026 Finalyze Inc. All Rights Reserved.",
        style: GoogleFonts.poppins(color: Colors.white24, fontSize: rs(context, 10)),
      ),
    );
  }
}
