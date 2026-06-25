import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../species/models/fish_specie.dart';

class SpeciesDetailScreen extends StatelessWidget {
  final FishSpecies fish;
  const SpeciesDetailScreen({super.key, required this.fish});

  static const primaryBlue = Color(0xFF1A5694);
  static const accentTeal = Color(0xFF2CB88E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverHeader(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      fish.name,
                      style: GoogleFonts.poppins(
                        fontSize: 26, fontWeight: FontWeight.bold, color: primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fish.urduName,
                      style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w500,
                        color: primaryBlue.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
                Text(
                  fish.category,
                  style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w600, color: accentTeal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fish.scientificName,
                  style: GoogleFonts.poppins(
                    fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    _statChip(Icons.public_rounded, fish.region),
                    const SizedBox(width: 10),
                    _statChip(Icons.calendar_month_rounded, fish.season),
                    const SizedBox(width: 10),
                    _statChip(Icons.payments_outlined, fish.marketValue),
                  ],
                ),
                const SizedBox(height: 24),

                _sectionCard(
                  icon: Icons.biotech_outlined,
                  title: "Freshness Indicators",
                  child: Column(
                    children: fish.freshnessIndicators
                        .map((fi) => _freshnessRow(fi))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),

                _sectionCard(
                  icon: Icons.waves_rounded,
                  title: "Habitat",
                  child: Text(
                    fish.habitat,
                    style: GoogleFonts.poppins(
                      color: Colors.blueGrey, fontSize: 13, height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _sectionCard(
                  icon: Icons.fitness_center_rounded,
                  title: "Nutrition (per 100g)",
                  child: Column(
                    children: [
                      _nutritionRow("Protein", fish.nutrition.protein),
                      _divider(),
                      _nutritionRow("Omega-3", fish.nutrition.omega3),
                      _divider(),
                      _nutritionRow("Fat", fish.nutrition.fat),
                      _divider(),
                      _nutritionRow("Calories", fish.nutrition.calories),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF0D2E5C),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            fish.imagePath.startsWith('assets/')
                ? Image.asset(fish.imagePath, fit: BoxFit.cover)
                : Image.network(
                    fish.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF0D2E5C),
                      child: const Icon(Icons.set_meal_rounded, color: Colors.white38, size: 80),
                    ),
                  ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC0D2E5C)],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 20, left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: accentTeal.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.set_meal_rounded, color: Colors.white, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      fish.category,
                      style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryBlue, size: 18),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.poppins(
                fontSize: 10, fontWeight: FontWeight.w600, color: primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentTeal, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _freshnessRow(FreshnessIndicator fi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(fi.icon, color: primaryBlue, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fi.title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, color: primaryBlue, fontSize: 13)),
                const SizedBox(height: 2),
                Text(fi.detail,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.blueGrey, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.blueGrey)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.bold, color: primaryBlue)),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.grey.shade100, height: 1);
}
