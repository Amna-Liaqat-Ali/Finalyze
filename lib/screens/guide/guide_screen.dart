import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_sizes.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  static const primaryBlue = Color(0xFF1A5694);
  static const lightBlueBg = Color(0xFFE8F1FF);
  static const accentTeal = Color(0xFF2CB88E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D2E5C), Color(0xFF1A5694), Color(0xFF0891B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(context),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: rsh(context, 32)),

                  _buildSectionHeader(context, "How to Scan", "Step-by-Step"),
                  SizedBox(height: rsh(context, 20)),

                  _buildStepCard(
                    context,
                    number: "1",
                    icon: Icons.camera_alt_outlined,
                    title: "Open the Scanner",
                    desc: "Tap 'Scan Fish Now' on the home screen or use the camera button. You can also upload an image from your gallery using 'Upload Image'.",
                  ),
                  _buildStepCard(
                    context,
                    number: "2",
                    icon: Icons.wb_sunny_outlined,
                    title: "Set Up Good Lighting",
                    desc: "Place the fish under natural or bright indoor light. Avoid harsh shadows and direct flash, which can distort the gill and eye colour the AI reads.",
                  ),
                  _buildStepCard(
                    context,
                    number: "3",
                    icon: Icons.center_focus_strong_outlined,
                    title: "Focus on Eyes and Gills",
                    desc: "Position the camera so the fish's eye and gill area fill most of the frame. These are the primary biological markers Finalyze analyses.",
                  ),
                  _buildStepCard(
                    context,
                    number: "4",
                    icon: Icons.crop_free_outlined,
                    title: "Hold Steady and Capture",
                    desc: "Keep the camera still and at roughly 15–20 cm from the fish. Tap the shutter, then review the image in the editor before submitting for analysis.",
                  ),
                  _buildStepCard(
                    context,
                    number: "5",
                    icon: Icons.analytics_outlined,
                    title: "Read Your Result",
                    desc: "Finalyze returns a freshness status (Fresh, Moderate, or Spoiled) with a confidence percentage. Check the full report in History for date, time, and species details.",
                  ),

                  SizedBox(height: rsh(context, 40)),

                  _buildSectionHeader(context, "Daily Scan Limit", "Free Plan"),
                  SizedBox(height: rsh(context, 16)),

                  _buildInfoCard(
                    context,
                    icon: Icons.timer_outlined,
                    title: "15 Scans Per Day",
                    body: "Free accounts can perform up to 15 AI scans within any 24-hour window. Once the limit is reached, a countdown shows when your quota resets. Upgrade to Premium for unlimited scans.",
                    color: const Color(0xFFE8F1FF),
                    iconColor: primaryBlue,
                  ),
                  SizedBox(height: rsh(context, 16)),

                  _buildInfoCard(
                    context,
                    icon: Icons.history_rounded,
                    title: "Scan History",
                    body: "Every successful scan is saved to your History tab. Tap any entry to open the Full Report, which shows the scanned image, species, confidence score, and the date and time of analysis.",
                    color: const Color(0xFFE8FFF5),
                    iconColor: accentTeal,
                  ),
                  SizedBox(height: rsh(context, 40)),

                  _buildSectionHeader(context, "Manual Verification", "Double-Check"),
                  SizedBox(height: rsh(context, 16)),

                  Text(
                    "Use these physical checks alongside the AI result for maximum confidence.",
                    style: GoogleFonts.poppins(
                      fontSize: rs(context, 13), color: Colors.blueGrey, height: 1.5,
                    ),
                  ),
                  SizedBox(height: rsh(context, 16)),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: rs(context, 16),
                    mainAxisSpacing: rsh(context, 16),
                    childAspectRatio: 0.72,
                    children: [
                      _buildManualCard(
                        context,
                        icon: Icons.air_outlined,
                        title: "Smell Test",
                        desc: "Should have a clean, oceanic scent. An ammonia or sour odour means spoilage.",
                      ),
                      _buildManualCard(
                        context,
                        icon: Icons.visibility_outlined,
                        title: "Clear Eyes",
                        desc: "Look for bright, bulging eyes. Cloudiness or sunken eyes indicate age.",
                      ),
                      _buildManualCard(
                        context,
                        icon: Icons.water_drop_outlined,
                        title: "Red Gills",
                        desc: "Gills should be vivid red or pink. Grey or brown colouring signals deterioration.",
                      ),
                      _buildManualCard(
                        context,
                        icon: Icons.back_hand_outlined,
                        title: "Firm Flesh",
                        desc: "Press the flesh — it should spring back instantly. Soft or mushy flesh is a spoilage sign.",
                      ),
                    ],
                  ),

                  SizedBox(height: rsh(context, 40)),
                  _buildSectionHeader(context, "Understanding Results", "AI Output"),
                  SizedBox(height: rsh(context, 16)),

                  _buildResultRow(
                    context,
                    color: accentTeal,
                    label: "Fresh",
                    desc: "Safe for immediate consumption, grilling, or storing up to 2 days. High confidence AI detection.",
                  ),
                  SizedBox(height: rsh(context, 10)),
                  _buildResultRow(
                    context,
                    color: Colors.orange,
                    label: "Moderate",
                    desc: "Cook thoroughly at high heat. Not suitable for raw consumption. Use the same day.",
                  ),
                  SizedBox(height: rsh(context, 10)),
                  _buildResultRow(
                    context,
                    color: Colors.redAccent,
                    label: "Spoiled",
                    desc: "Not safe for consumption. Discard immediately. No recipe recommendations are shown.",
                  ),

                  SizedBox(height: rsh(context, 100)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(rs(context, 24)),
      padding: EdgeInsets.all(rs(context, 24)),
      decoration: BoxDecoration(
        color: lightBlueBg,
        borderRadius: BorderRadius.circular(rs(context, 24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(rs(context, 12)),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(rs(context, 12)),
            ),
            child: Icon(Icons.biotech_outlined, color: Colors.white, size: rs(context, 28)),
          ),
          SizedBox(width: rs(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "How to Use Finalyze",
                  style: GoogleFonts.poppins(
                    fontSize: rs(context, 20), fontWeight: FontWeight.bold, color: primaryBlue,
                  ),
                ),
                SizedBox(height: rsh(context, 8)),
                Text(
                  "Finalyze uses a TFLite AI model trained on fish eye and gill images to instantly assess freshness. Follow this guide to get the most accurate results.",
                  style: GoogleFonts.poppins(
                    fontSize: rs(context, 13), color: primaryBlue.withOpacity(0.8), height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String badge) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: rs(context, 20), fontWeight: FontWeight.bold, color: Colors.black,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rsh(context, 6)),
          decoration: BoxDecoration(
            color: lightBlueBg,
            borderRadius: BorderRadius.circular(rs(context, 20)),
          ),
          child: Text(
            badge,
            style: GoogleFonts.poppins(
              color: primaryBlue, fontSize: rs(context, 12), fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(BuildContext context, {
    required String number,
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: rsh(context, 16)),
      padding: EdgeInsets.all(rs(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs(context, 20)),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: rs(context, 20),
            backgroundColor: lightBlueBg,
            child: Text(
              number,
              style: GoogleFonts.poppins(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: rs(context, 14)),
            ),
          ),
          SizedBox(width: rs(context, 20)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: rs(context, 20), color: primaryBlue),
                    SizedBox(width: rs(context, 8)),
                    Text(
                      title,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: rs(context, 15)),
                    ),
                  ],
                ),
                SizedBox(height: rsh(context, 8)),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600, fontSize: rs(context, 13), height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(rs(context, 18)),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(rs(context, 18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: rs(context, 24)),
          SizedBox(width: rs(context, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: rs(context, 14), color: iconColor,
                  ),
                ),
                SizedBox(height: rsh(context, 4)),
                Text(
                  body,
                  style: GoogleFonts.poppins(
                    fontSize: rs(context, 12), color: Colors.blueGrey, height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualCard(BuildContext context, {required IconData icon, required String title, required String desc}) {
    return Container(
      padding: EdgeInsets.all(rs(context, 16)),
      decoration: BoxDecoration(
        color: lightBlueBg.withOpacity(0.3),
        borderRadius: BorderRadius.circular(rs(context, 20)),
        border: Border.all(color: lightBlueBg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(rs(context, 10)),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: accentTeal, size: rs(context, 24)),
          ),
          SizedBox(height: rsh(context, 12)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: rs(context, 14)),
          ),
          SizedBox(height: rsh(context, 8)),
          Flexible(
            child: Text(
              desc,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: rs(context, 11), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(BuildContext context, {required Color color, required String label, required String desc}) {
    return Container(
      padding: EdgeInsets.all(rs(context, 16)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(rs(context, 14)),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: rs(context, 12), height: rs(context, 12),
            margin: EdgeInsets.only(top: rsh(context, 3)),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: rs(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: rs(context, 14), color: color,
                  ),
                ),
                SizedBox(height: rsh(context, 2)),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: rs(context, 12), color: Colors.blueGrey, height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
