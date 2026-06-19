import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/app_back_button.dart';
import '../../../widgets/app_inner_bar.dart';
import '../../species/models/fish_specie.dart';

class SpeciesDetailScreen extends StatelessWidget {
  final FishSpecies fish;
  const SpeciesDetailScreen({super.key, required this.fish});

  static const primaryBlue = Color(0xFF1A5694);
  static const accentTeal = Color(0xFF4EE3AA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppInnerBar(title: fish.name, onBack: () => Navigator.pop(context)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.asset(
                      fish.imagePath,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: accentTeal.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              color: primaryBlue,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "98% Freshness Score",
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fish.name,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      Text(
                        "Lutjanus campechanus",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatCard(
                            "REGION",
                            "Gulf of Mexico",
                            Icons.public,
                          ),
                          _buildStatCard(
                            "SEASON",
                            "Year-round",
                            Icons.calendar_today,
                          ),
                          _buildStatCard(
                            "MARKET VALUE",
                            "Premium",
                            Icons.payments_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      _buildContentCard(
                        title: "Freshness Indicators",
                        icon: Icons.biotech_outlined,
                        child: Column(
                          children: [
                            _indicatorRow(
                              Icons.visibility_outlined,
                              "Clear bulging eyes",
                              "Sign of immediate post-catch status",
                            ),
                            _indicatorRow(
                              Icons.water_drop_outlined,
                              "Bright red gills",
                              "Oxygen-rich, indicates proper cold chain",
                            ),
                            _indicatorRow(
                              Icons.fingerprint,
                              "Firm flesh",
                              fish.tip,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildContentCard(
                        title: "Habitat",
                        icon: Icons.tsunami,
                        child: Text(
                          "${fish.name} typically inhabit deep sea rocky reefs and shipwrecks between 30 to 200 feet deep.",
                          style: GoogleFonts.poppins(
                            color: Colors.blueGrey,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildContentCard(
                        title: "Nutrition",
                        icon: Icons.fitness_center,
                        child: Column(
                          children: [
                            _nutritionRow("Protein", "22g"),
                            _nutritionRow("Omega-3", "0.5g"),
                            _nutritionRow("Calories", "109"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryBlue, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00796B), size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _indicatorRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: primaryBlue, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
