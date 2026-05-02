import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/recipe.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  static const primaryBlue = Color(0xFF1A5694);
  static const accentTeal = Color(0xFF2CB88E);
  static const softBg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    bool isAsset = recipe.imageUrl.startsWith('assets/');

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            elevation: 0,
            stretch: true,
            backgroundColor: primaryBlue,
            leading: IconButton(
              icon: _buildBlurCircle(
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: _buildBlurCircle(
                  const Icon(
                    Icons.favorite_border_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Hero(
                tag: recipe.imageUrl,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    isAsset
                        ? Image.asset(recipe.imageUrl, fit: BoxFit.cover)
                        : Image.network(recipe.imageUrl, fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                            Colors.white.withOpacity(0.9),
                            Colors.white,
                          ],
                          stops: const [0.0, 0.4, 0.9, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: GoogleFonts.poppins(
                      color: primaryBlue,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryBadge(recipe.category),

                  const SizedBox(height: 32),

                  _buildStatsRow(),

                  const SizedBox(height: 40),

                  _buildSectionHeader(
                    "Ingredients",
                    "${recipe.ingredients.length} items",
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.ingredients.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 50,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemBuilder: (context, index) =>
                        _buildIngredientItem(recipe.ingredients[index]),
                  ),

                  const SizedBox(height: 40),

                  _buildSectionHeader(
                    "Directions",
                    "${recipe.instructions.length} steps",
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.instructions.length,
                    itemBuilder: (context, index) {
                      return _buildDirectionCard(
                        index + 1,
                        recipe.instructions[index],
                      );
                    },
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(Widget child) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.black.withOpacity(0.2),
          child: child,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: accentTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        category.toUpperCase(),
        style: GoogleFonts.poppins(
          color: accentTeal,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: softBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blueGrey.shade50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.access_time_filled_rounded,
            "${recipe.cookTimeMinutes}m",
            "TIME",
          ),
          _buildStatDivider(),
          _buildStatItem(
            Icons.leaderboard_rounded,
            recipe.difficulty.name,
            "LEVEL",
          ),
          _buildStatDivider(),
          _buildStatItem(
            Icons.local_fire_department_rounded,
            "${recipe.spiceLevel * 100}cal",
            "ENERGY",
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: primaryBlue, size: 22),
        const SizedBox(height: 6),
        Text(
          value.toUpperCase(),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: primaryBlue,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.blueGrey,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.blueGrey.withOpacity(0.1),
    );
  }

  Widget _buildSectionHeader(String title, String trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        Text(
          trailing,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.blueGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientItem(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: softBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade50),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.add_circle_outline_rounded,
            color: accentTeal,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: primaryBlue.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionCard(int step, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.shade50),
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
            radius: 14,
            backgroundColor: primaryBlue,
            child: Text(
              "$step",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.blueGrey.shade800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
