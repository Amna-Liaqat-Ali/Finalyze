import 'package:Finalyze/screens/cook/widgets/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data/recipe_data.dart';
import 'models/recipe.dart';

class RecipeScreen extends StatefulWidget {
  final String? freshnessStatus;

  const RecipeScreen({super.key, this.freshnessStatus});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  static const primaryBlue = Color(0xFF1A5694);
  static const accentTeal = Color(0xFF2CB88E);
  static const softBg = Color(0xFFF8FAFC);

  final List<Recipe> _allRecipes = RecipeMockData.getRecipes();
  List<Recipe> _displayRecipes = [];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _applyFilter('All');
  }

  void _applyFilter(String category) {
    setState(() {
      _selectedCategory = category;
      List<Recipe> base = category == 'All'
          ? _allRecipes
          : _allRecipes.where((r) => r.category == category).toList();

      // If freshness context provided, sort matched recipes to top
      if (widget.freshnessStatus != null &&
          widget.freshnessStatus != 'spoiled') {
        final matched =
            base.where((r) => r.suitableFor.contains(widget.freshnessStatus)).toList();
        final others =
            base.where((r) => !r.suitableFor.contains(widget.freshnessStatus)).toList();
        _displayRecipes = [...matched, ...others];
      } else {
        _displayRecipes = base;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.freshnessStatus;
    final isSpoiled = status == 'spoiled';

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
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
            onPressed: () => showSearch(
              context: context,
              delegate: RecipeSearchDelegate(allRecipes: _allRecipes),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: isSpoiled ? _buildSpoiledWarning() : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (status != null) _buildFreshnessBanner(status),
          _buildCategoryChips(),
          Expanded(
            child: _displayRecipes.isEmpty
                ? Center(
                    child: Text("No recipes found.",
                        style: GoogleFonts.poppins(color: Colors.blueGrey)),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: _displayRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _displayRecipes[index];
                      final isMatch = status != null &&
                          recipe.suitableFor.contains(status);
                      return _buildRecipeCard(recipe, highlight: isMatch);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreshnessBanner(String status) {
    final isFresh = status == 'fresh';
    final color = isFresh ? accentTeal : Colors.orange;
    final icon = isFresh ? Icons.check_circle_rounded : Icons.warning_amber_rounded;
    final title = isFresh ? "Best for Fresh Fish" : "Suitable for Moderate Fish";
    final subtitle = isFresh
        ? "Recipes below preserve natural flavour — ideal for your scan result."
        : "These recipes use thorough cooking methods suited for your scan result.";

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 13)),
                Text(subtitle,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.blueGrey,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    const cats = ['All', 'Fried', 'Curry', 'Grilled', 'Regional'];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = cats[i];
          final active = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => _applyFilter(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: active ? primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: active ? primaryBlue : Colors.blueGrey.shade100),
              ),
              child: Text(cat,
                  style: GoogleFonts.poppins(
                      color: active ? Colors.white : Colors.blueGrey,
                      fontWeight:
                          active ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpoiledWarning() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.no_meals_rounded,
                  color: Colors.redAccent, size: 64),
            ),
            const SizedBox(height: 24),
            Text("Not Safe to Cook",
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent)),
            const SizedBox(height: 12),
            Text(
              "The scanned fish was identified as spoiled. It is not suitable for consumption or cooking. Please discard it immediately.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.blueGrey,
                  height: 1.6),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              label: Text("Go Back",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryBlue,
                side: const BorderSide(color: Color(0xFF1A5694)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe, {bool highlight = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: highlight
                ? accentTeal.withOpacity(0.12)
                : primaryBlue.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: highlight ? accentTeal.withOpacity(0.35) : Colors.blueGrey.shade50,
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: recipe.imageUrl.startsWith('assets/')
                          ? Image.asset(
                              recipe.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: softBg,
                                child: const Icon(Icons.broken_image, color: Colors.blueGrey),
                              ),
                            )
                          : Image.network(
                              recipe.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: softBg,
                                child: const Icon(Icons.broken_image, color: Colors.blueGrey),
                              ),
                            ),
                    ),
                    if (highlight)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: accentTeal,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text("Best Match",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => setState(
                            () => recipe.isFavorite = !recipe.isFavorite),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Icon(
                            recipe.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: const Color(0xFFFF1744),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStat(
                          Icons.access_time_rounded,
                          '${recipe.cookTimeMinutes} min',
                          accentTeal,
                        ),
                        const SizedBox(width: 16),
                        _buildStat(
                          Icons.bar_chart_rounded,
                          recipe.difficulty.name.toUpperCase(),
                          primaryBlue,
                        ),
                        const Spacer(),
                        _buildSpiceLevel(recipe.spiceLevel),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.blueGrey,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSpiceLevel(int level) {
    return Row(
      children: List.generate(
        3,
        (i) => Icon(
          Icons.whatshot_rounded,
          size: 14,
          color: i < level ? Colors.orange : Colors.blueGrey.withOpacity(0.2),
        ),
      ),
    );
  }
}  // end _RecipeScreenState

class RecipeSearchDelegate extends SearchDelegate {
  final List<Recipe> allRecipes;
  RecipeSearchDelegate({required this.allRecipes});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1A5694)),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Color(0xFF1A5694)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.blueGrey),
        border: InputBorder.none,
      ),
      scaffoldBackgroundColor: Colors.white,
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear_rounded),
      onPressed: () => query = '',
    ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _searchList();

  @override
  Widget buildSuggestions(BuildContext context) => _searchList();

  Widget _searchList() {
    final results = allRecipes
        .where((r) => r.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(
          results[index].title,
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A5694),
            fontSize: 14,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => RecipeDetailScreen(recipe: results[index]),
            ),
          );
        },
      ),
    );
  }
}
