import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_sizes.dart';
import '../../../widgets/app_back_button.dart';
import '../models/recipe.dart';
import '../services/recipe_interaction_store.dart';
import 'cooking_flow_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  static const primaryBlue = Color(0xFF1A5694);
  static const accentTeal = Color(0xFF2CB88E);
  static const softBg = Color(0xFFF8FAFC);

  Recipe get recipe => widget.recipe;

  void _toggleFavorite() {
    setState(() => recipe.isFavorite = !recipe.isFavorite);
    RecipeInteractionStore.setFavorite(recipe.id, recipe.isFavorite);
  }

  void _setRating(double value) {
    setState(() => recipe.rating = value);
    RecipeInteractionStore.setRating(recipe.id, value);
  }

  Future<void> _startCooking() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CookingFlowScreen(recipe: recipe),
      ),
    );
    if (mounted) setState(() {});
  }

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
                    recipe.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: recipe.isFavorite ? const Color(0xFFFF1744) : Colors.white,
                    size: rs(context, 20),
                  ),
                ),
                onPressed: _toggleFavorite,
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

                  SizedBox(height: rsh(context, 24)),

                  _buildRatingSection(context),

                  SizedBox(height: rsh(context, 32)),

                  _buildStatsRow(context),

                  SizedBox(height: rsh(context, 40)),

                  _buildStartCookingButton(context),

                  SizedBox(height: rsh(context, 60)),
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

  Widget _buildRatingSection(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          final starValue = i + 1;
          final filled = starValue <= recipe.rating.round();
          return GestureDetector(
            onTap: () => _setRating(starValue.toDouble()),
            child: Padding(
              padding: EdgeInsets.only(right: rs(context, 4)),
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_border_rounded,
                color: Colors.amber,
                size: rs(context, 26),
              ),
            ),
          );
        }),
        SizedBox(width: rs(context, 8)),
        Text(
          recipe.rating > 0 ? recipe.rating.toStringAsFixed(1) : "Tap to rate",
          style: GoogleFonts.poppins(
            fontSize: rs(context, 13),
            color: Colors.blueGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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

  Widget _buildStartCookingButton(BuildContext context) {
    return GestureDetector(
      onTap: _startCooking,
      child: Container(
        width: double.infinity,
        height: rsh(context, 56),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A5694), Color(0xFF0891B2), Color(0xFF2CB88E)],
          ),
          borderRadius: BorderRadius.circular(rs(context, 16)),
          boxShadow: [
            BoxShadow(
              color: accentTeal.withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restaurant_rounded, color: Colors.white, size: rs(context, 20)),
              SizedBox(width: rs(context, 10)),
              Text(
                "Start Cooking",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: rs(context, 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
