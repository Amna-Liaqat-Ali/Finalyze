import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_sizes.dart';
import '../../../widgets/app_back_button.dart';
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
            expandedHeight: sh(context, 0.45),
            pinned: true,
            elevation: 0,
            stretch: true,
            backgroundColor: primaryBlue,
            leading: Padding(
              padding: EdgeInsets.only(left: rs(context, 12)),
              child: Center(
                child: AppBackButton(isGlass: true, onTap: () => Navigator.pop(context)),
              ),
            ),
            actions: [
              IconButton(
                icon: _buildBlurCircle(
                  Icon(
                    Icons.favorite_border_rounded,
                    color: Colors.white,
                    size: rs(context, 20),
                  ),
                ),
                onPressed: () {},
              ),
              SizedBox(width: rs(context, 16)),
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
              padding: EdgeInsets.symmetric(horizontal: rs(context, 24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: GoogleFonts.poppins(
                      color: primaryBlue,
                      fontSize: rs(context, 28),
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: rsh(context, 12)),
                  _buildCategoryBadge(context, recipe.category),

                  SizedBox(height: rsh(context, 32)),

                  _buildStatsRow(context),

                  SizedBox(height: rsh(context, 40)),

                  _buildSectionHeader(
                    context,
                    "Ingredients",
                    "${recipe.ingredients.length} items",
                  ),
                  SizedBox(height: rsh(context, 16)),
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.ingredients.length,
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: rsh(context, 50),
                          crossAxisSpacing: rs(context, 12),
                          mainAxisSpacing: rsh(context, 12),
                        ),
                    itemBuilder: (context, index) =>
                        _buildIngredientItem(context, recipe.ingredients[index]),
                  ),

                  SizedBox(height: rsh(context, 40)),

                  _buildSectionHeader(
                    context,
                    "Directions",
                    "${recipe.instructions.length} steps",
                  ),
                  SizedBox(height: rsh(context, 20)),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.instructions.length,
                    itemBuilder: (context, index) {
                      return _buildDirectionCard(
                        context,
                        index + 1,
                        recipe.instructions[index],
                      );
                    },
                  ),

                  SizedBox(height: rsh(context, 120)),
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

  Widget _buildCategoryBadge(BuildContext context, String category) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 14), vertical: rsh(context, 6)),
      decoration: BoxDecoration(
        color: accentTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(rs(context, 30)),
      ),
      child: Text(
        category.toUpperCase(),
        style: GoogleFonts.poppins(
          color: accentTeal,
          fontSize: rs(context, 11),
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(rs(context, 20)),
      decoration: BoxDecoration(
        color: softBg,
        borderRadius: BorderRadius.circular(rs(context, 24)),
        border: Border.all(color: Colors.blueGrey.shade50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            Icons.access_time_filled_rounded,
            "${recipe.cookTimeMinutes}m",
            "TIME",
          ),
          _buildStatDivider(context),
          _buildStatItem(
            context,
            Icons.leaderboard_rounded,
            recipe.difficulty.name,
            "LEVEL",
          ),
          _buildStatDivider(context),
          _buildStatItem(
            context,
            Icons.local_fire_department_rounded,
            "${recipe.spiceLevel * 100}cal",
            "ENERGY",
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: primaryBlue, size: rs(context, 22)),
        SizedBox(height: rsh(context, 6)),
        Text(
          value.toUpperCase(),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: rs(context, 14),
            color: primaryBlue,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.blueGrey,
            fontSize: rs(context, 9),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(BuildContext context) {
    return Container(
      height: rsh(context, 30),
      width: 1,
      color: Colors.blueGrey.withOpacity(0.1),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: rs(context, 20),
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        Text(
          trailing,
          style: GoogleFonts.poppins(
            fontSize: rs(context, 13),
            color: Colors.blueGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientItem(BuildContext context, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 12)),
      decoration: BoxDecoration(
        color: softBg,
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(color: Colors.blueGrey.shade50),
      ),
      child: Row(
        children: [
          Icon(
            Icons.add_circle_outline_rounded,
            color: accentTeal,
            size: rs(context, 18),
          ),
          SizedBox(width: rs(context, 10)),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: rs(context, 13),
                color: primaryBlue.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionCard(BuildContext context, int step, String text) {
    return Container(
      margin: EdgeInsets.only(bottom: rsh(context, 16)),
      padding: EdgeInsets.all(rs(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs(context, 16)),
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
            radius: rs(context, 14),
            backgroundColor: primaryBlue,
            child: Text(
              "$step",
              style: TextStyle(
                color: Colors.white,
                fontSize: rs(context, 12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: rs(context, 16)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: rs(context, 14),
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
