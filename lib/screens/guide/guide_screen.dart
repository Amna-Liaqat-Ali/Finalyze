import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
            _buildHeroCard(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  _buildSectionHeader("How to Scan", "Step-by-Step"),
                  const SizedBox(height: 20),

                  _buildStepCard(
                    number: "1",
                    icon: Icons.camera_alt_outlined,
                    title: "Open the Scanner",
                    desc: "Tap 'Scan Fish Now' on the home screen or use the camera button. You can also upload an image from your gallery using 'Upload Image'.",
                  ),
                  _buildStepCard(
                    number: "2",
                    icon: Icons.wb_sunny_outlined,
                    title: "Set Up Good Lighting",
                    desc: "Place the fish under natural or bright indoor light. Avoid harsh shadows and direct flash, which can distort the gill and eye colour the AI reads.",
                  ),
                  _buildStepCard(
                    number: "3",
                    icon: Icons.center_focus_strong_outlined,
                    title: "Focus on Eyes and Gills",
                    desc: "Position the camera so the fish's eye and gill area fill most of the frame. These are the primary biological markers Finalyze analyses.",
                  ),
                  _buildStepCard(
                    number: "4",
                    icon: Icons.crop_free_outlined,
                    title: "Hold Steady and Capture",
                    desc: "Keep the camera still and at roughly 15–20 cm from the fish. Tap the shutter, then review the image in the editor before submitting for analysis.",
                  ),
                  _buildStepCard(
                    number: "5",
                    icon: Icons.analytics_outlined,
                    title: "Read Your Result",
                    desc: "Finalyze returns a freshness status (Fresh, Moderate, or Spoiled) with a confidence percentage. Check the full report in History for date, time, and species details.",
                  ),

                  const SizedBox(height: 40),

                  _buildSectionHeader("Daily Scan Limit", "Free Plan"),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    icon: Icons.timer_outlined,
                    title: "15 Scans Per Day",
                    body: "Free accounts can perform up to 15 AI scans within any 24-hour window. Once the limit is reached, a countdown shows when your quota resets. Upgrade to Premium for unlimited scans.",
                    color: const Color(0xFFE8F1FF),
                    iconColor: primaryBlue,
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    icon: Icons.history_rounded,
                    title: "Scan History",
                    body: "Every successful scan is saved to your History tab. Tap any entry to open the Full Report, which shows the scanned image, species, confidence score, and the date and time of analysis.",
                    color: const Color(0xFFE8FFF5),
                    iconColor: accentTeal,
                  ),
                  const SizedBox(height: 40),

                  _buildSectionHeader("Manual Verification", "Double-Check"),
                  const SizedBox(height: 16),

                  Text(
                    "Use these physical checks alongside the AI result for maximum confidence.",
                    style: GoogleFonts.poppins(
                      fontSize: 13, color: Colors.blueGrey, height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _buildManualCard(
                        icon: Icons.air_outlined,
                        title: "Smell Test",
                        desc: "Should have a clean, oceanic scent. An ammonia or sour odour means spoilage.",
                      ),
                      _buildManualCard(
                        icon: Icons.visibility_outlined,
                        title: "Clear Eyes",
                        desc: "Look for bright, bulging eyes. Cloudiness or sunken eyes indicate age.",
                      ),
                      _buildManualCard(
                        icon: Icons.water_drop_outlined,
                        title: "Red Gills",
                        desc: "Gills should be vivid red or pink. Grey or brown colouring signals deterioration.",
                      ),
                      _buildManualCard(
                        icon: Icons.back_hand_outlined,
                        title: "Firm Flesh",
                        desc: "Press the flesh — it should spring back instantly. Soft or mushy flesh is a spoilage sign.",
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  _buildSectionHeader("Understanding Results", "AI Output"),
                  const SizedBox(height: 16),

                  _buildResultRow(
                    color: accentTeal,
                    label: "Fresh",
                    desc: "Safe for immediate consumption, grilling, or storing up to 2 days. High confidence AI detection.",
                  ),
                  const SizedBox(height: 10),
                  _buildResultRow(
                    color: Colors.orange,
                    label: "Moderate",
                    desc: "Cook thoroughly at high heat. Not suitable for raw consumption. Use the same day.",
                  ),
                  const SizedBox(height: 10),
                  _buildResultRow(
                    color: Colors.redAccent,
                    label: "Spoiled",
                    desc: "Not safe for consumption. Discard immediately. No recipe recommendations are shown.",
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: lightBlueBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.biotech_outlined, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "How to Use Finalyze",
                  style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Finalyze uses a TFLite AI model trained on fish eye and gill images to instantly assess freshness. Follow this guide to get the most accurate results.",
                  style: GoogleFonts.poppins(
                    fontSize: 13, color: primaryBlue.withOpacity(0.8), height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String badge) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: lightBlueBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badge,
            style: GoogleFonts.poppins(
              color: primaryBlue, fontSize: 12, fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required String number,
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            radius: 20,
            backgroundColor: lightBlueBg,
            child: Text(
              number,
              style: GoogleFonts.poppins(color: primaryBlue, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: primaryBlue),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600, fontSize: 13, height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String body,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 14, color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.blueGrey, height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualCard({required IconData icon, required String title, required String desc}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightBlueBg.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lightBlueBg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: accentTeal, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow({required Color color, required String label, required String desc}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12, height: 12,
            margin: const EdgeInsets.only(top: 3),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 14, color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.blueGrey, height: 1.4,
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
