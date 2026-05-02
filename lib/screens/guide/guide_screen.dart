import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  // --- Theme Constants ---
  static const primaryBlue = Color(0xFF1A5694);
  static const lightBlueBg = Color(0xFFE8F1FF);
  static const accentTeal = Color(0xFF2CB88E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Scan Guide",
          style: GoogleFonts.poppins(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [],
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

                  _buildSectionHeader("Scanning Best Practices", "Pro Guide"),
                  const SizedBox(height: 20),

                  _buildStepCard(
                    number: "1",
                    icon: Icons.wb_sunny_outlined,
                    title: "Lighting",
                    desc:
                        "Use natural, diffused light. Avoid direct harsh sunlight or heavy shadows on the specimen.",
                  ),
                  _buildStepCard(
                    number: "2",
                    icon: Icons.center_focus_strong_outlined,
                    title: "Focus",
                    desc:
                        "Ensure the lens is clean and the subject is in sharp focus. Tap the screen to lock focus on the center.",
                  ),
                  _buildStepCard(
                    number: "3",
                    icon: Icons.crop_free_outlined,
                    title: "Framing",
                    desc:
                        "Keep the entire specimen within the guide lines. Maintain a distance of roughly 15-20cm.",
                  ),

                  const SizedBox(height: 40),

                  Text(
                    "Manual Verification",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _buildManualCard(
                        icon: Icons.air,
                        title: "Smell Test",
                        desc:
                            "Should have a clean, oceanic scent; never ammonia-like.",
                      ),
                      _buildManualCard(
                        icon: Icons.visibility_outlined,
                        title: "Clear Eyes",
                        desc:
                            "Look for bright, bulging eyes. Cloudiness indicates age.",
                      ),
                      _buildManualCard(
                        icon: Icons.water_drop_outlined,
                        title: "Red Gills",
                        desc:
                            "Fresh specimens display vivid red or deep pink gills.",
                      ),
                      _buildManualCard(
                        icon: Icons.back_hand_outlined,
                        title: "Firm Flesh",
                        desc:
                            "Meat should spring back instantly when pressed gently.",
                      ),
                    ],
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
            child: const Icon(
              Icons.verified_user_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Get 100% Accuracy",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Follow these scientific protocols to ensure the highest fidelity in AI fresh-ness analysis.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: primaryBlue.withOpacity(0.8),
                    height: 1.5,
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
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
              color: primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
              style: GoogleFonts.poppins(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
              ),
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
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
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
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentTeal, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
