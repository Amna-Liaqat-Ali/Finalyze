import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_sizes.dart';
import 'models/recipe.dart';
import 'services/recipe_interaction_store.dart';
import 'widgets/recipe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Recipe> allRecipes;

  const FavoritesScreen({super.key, required this.allRecipes});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  static const primaryBlue = Color(0xFF1A5694);
  static const accentTeal = Color(0xFF2CB88E);
  static const softBg = Color(0xFFF8FAFC);

  List<Recipe> get _favorites =>
      widget.allRecipes.where((r) => r.isFavorite).toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));

  @override
  Widget build(BuildContext context) {
    final favorites = _favorites;
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D2E5C), Color(0xFF1A5694), Color(0xFF0891B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: rs(context, 20)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Favorites",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: rs(context, 16)),
        ),
      ),
      body: favorites.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(rs(context, 20)),
              itemCount: favorites.length,
              itemBuilder: (context, index) => _buildFavoriteCard(context, favorites[index]),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(rs(context, 40)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, color: Colors.blueGrey.shade200, size: rs(context, 64)),
            SizedBox(height: rsh(context, 20)),
            Text(
              "No favorites yet",
              style: GoogleFonts.poppins(
                fontSize: rs(context, 18),
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            SizedBox(height: rsh(context, 8)),
            Text(
              "Tap the heart icon on any recipe to save it here.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: rs(context, 13), color: Colors.blueGrey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, Recipe recipe) {
    return Container(
      margin: EdgeInsets.only(bottom: rsh(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs(context, 18)),
        boxShadow: [
          BoxShadow(color: primaryBlue.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 6)),
        ],
        border: Border.all(color: Colors.blueGrey.shade50),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(rs(context, 18)),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)),
            );
            if (mounted) setState(() {});
          },
          child: Padding(
            padding: EdgeInsets.all(rs(context, 12)),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(rs(context, 14)),
                  child: SizedBox(
                    width: rs(context, 72),
                    height: rs(context, 72),
                    child: recipe.imageUrl.startsWith('assets/')
                        ? Image.asset(recipe.imageUrl, fit: BoxFit.cover)
                        : Image.network(
                            recipe.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: softBg,
                              child: const Icon(Icons.broken_image, color: Colors.blueGrey),
                            ),
                          ),
                  ),
                ),
                SizedBox(width: rs(context, 14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: rs(context, 15), color: primaryBlue),
                      ),
                      SizedBox(height: rsh(context, 6)),
                      Row(
                        children: [
                          if (recipe.rating > 0) ...[
                            Icon(Icons.star_rounded, color: Colors.amber, size: rs(context, 15)),
                            SizedBox(width: rs(context, 3)),
                            Text(
                              recipe.rating.toStringAsFixed(1),
                              style: GoogleFonts.poppins(fontSize: rs(context, 11), color: Colors.blueGrey, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: rs(context, 10)),
                          ],
                          Icon(Icons.access_time_rounded, color: accentTeal, size: rs(context, 13)),
                          SizedBox(width: rs(context, 3)),
                          Text(
                            "${recipe.cookTimeMinutes} min",
                            style: GoogleFonts.poppins(fontSize: rs(context, 11), color: Colors.blueGrey, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => recipe.isFavorite = false);
                    RecipeInteractionStore.setFavorite(recipe.id, false);
                  },
                  child: Icon(Icons.favorite_rounded, color: const Color(0xFFFF1744), size: rs(context, 22)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
