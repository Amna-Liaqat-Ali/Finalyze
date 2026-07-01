import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_sizes.dart';
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
            padding: EdgeInsets.fromLTRB(rs(context, 20), rsh(context, 20), rs(context, 20), rsh(context, 40)),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      fish.name,
                      style: GoogleFonts.poppins(
                        fontSize: rs(context, 26), fontWeight: FontWeight.bold, color: primaryBlue,
                      ),
                    ),
                    SizedBox(width: rs(context, 8)),
                    Text(
                      fish.urduName,
                      style: GoogleFonts.poppins(
                        fontSize: rs(context, 20), fontWeight: FontWeight.w500,
                        color: primaryBlue.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
                Text(
                  fish.category,
                  style: GoogleFonts.poppins(
                    fontSize: rs(context, 13), fontWeight: FontWeight.w600, color: accentTeal,
                  ),
                ),
                SizedBox(height: rsh(context, 2)),
                Text(
                  fish.scientificName,
                  style: GoogleFonts.poppins(
                    fontSize: rs(context, 12), fontStyle: FontStyle.italic, color: Colors.blueGrey,
                  ),
                ),
                SizedBox(height: rsh(context, 20)),

                Row(
                  children: [
                    _statChip(context, Icons.public_rounded, fish.region),
                    SizedBox(width: rs(context, 10)),
                    _statChip(context, Icons.calendar_month_rounded, fish.season),
                    SizedBox(width: rs(context, 10)),
                    _statChip(context, Icons.payments_outlined, fish.marketValue),
                  ],
                ),
                SizedBox(height: rsh(context, 24)),

                _sectionCard(
                  context,
                  icon: Icons.biotech_outlined,
                  title: "Freshness Indicators",
                  child: Column(
                    children: fish.freshnessIndicators
                        .map((fi) => _freshnessRow(context, fi))
                        .toList(),
                  ),
                ),
                SizedBox(height: rsh(context, 16)),

                _sectionCard(
                  context,
                  icon: Icons.waves_rounded,
                  title: "Habitat",
                  child: Text(
                    fish.habitat,
                    style: GoogleFonts.poppins(
                      color: Colors.blueGrey, fontSize: rs(context, 13), height: 1.6,
                    ),
                  ),
                ),
                SizedBox(height: rsh(context, 16)),

                _sectionCard(
                  context,
                  icon: Icons.fitness_center_rounded,
                  title: "Nutrition (per 100g)",
                  child: Column(
                    children: [
                      _nutritionRow(context, "Protein", fish.nutrition.protein),
                      _divider(),
                      _nutritionRow(context, "Omega-3", fish.nutrition.omega3),
                      _divider(),
                      _nutritionRow(context, "Fat", fish.nutrition.fat),
                      _divider(),
                      _nutritionRow(context, "Calories", fish.nutrition.calories),
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
      expandedHeight: sh(context, 0.33),
      pinned: true,
      backgroundColor: const Color(0xFF0D2E5C),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: rs(context, 20)),
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
                      child: Icon(Icons.set_meal_rounded, color: Colors.white38, size: rs(context, 80)),
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
              bottom: rsh(context, 20), left: rs(context, 20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: rs(context, 14), vertical: rsh(context, 7)),
                decoration: BoxDecoration(
                  color: accentTeal.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(rs(context, 30)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.set_meal_rounded, color: Colors.white, size: rs(context, 15)),
                    SizedBox(width: rs(context, 6)),
                    Text(
                      fish.category,
                      style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: rs(context, 12),
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

  Widget _statChip(BuildContext context, IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: rsh(context, 10), horizontal: rs(context, 8)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rs(context, 14)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryBlue, size: rs(context, 18)),
            SizedBox(height: rsh(context, 5)),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.poppins(
                fontSize: rs(context, 10), fontWeight: FontWeight.w600, color: primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(BuildContext context, {required IconData icon, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 18)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs(context, 18)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentTeal, size: rs(context, 20)),
              SizedBox(width: rs(context, 10)),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: rs(context, 16), fontWeight: FontWeight.bold, color: primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: rsh(context, 14)),
          child,
        ],
      ),
    );
  }

  Widget _freshnessRow(BuildContext context, FreshnessIndicator fi) {
    return Padding(
      padding: EdgeInsets.only(bottom: rsh(context, 14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: rs(context, 40), height: rs(context, 40),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FD),
              borderRadius: BorderRadius.circular(rs(context, 10)),
            ),
            child: Icon(fi.icon, color: primaryBlue, size: rs(context, 20)),
          ),
          SizedBox(width: rs(context, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fi.title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, color: primaryBlue, fontSize: rs(context, 13))),
                SizedBox(height: rsh(context, 2)),
                Text(fi.detail,
                    style: GoogleFonts.poppins(
                        fontSize: rs(context, 12), color: Colors.blueGrey, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutritionRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rsh(context, 8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(fontSize: rs(context, 13), color: Colors.blueGrey)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: rs(context, 15), fontWeight: FontWeight.bold, color: primaryBlue)),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.grey.shade100, height: 1);
}
