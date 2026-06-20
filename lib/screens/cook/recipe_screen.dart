import 'package:Finalyze/screens/cook/widgets/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data/recipe_data.dart';
import 'models/recipe.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  static const primaryBlue = Color(0xFF1A5694);
  static const accentTeal = Color(0xFF2CB88E);
  static const softBg = Color(0xFFF8FAFC);

  final List<Recipe> _allRecipes = RecipeMockData.getRecipes();
  List<Recipe> _filteredRecipes = [];
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Fried',
    'Curry',
    'Grilled',
    'Regional',
  ];

  @override
  void initState() {
    super.initState();
    _filteredRecipes = _allRecipes;
  }

  void _filterRecipes(String category) {
    setState(() {
      _selectedCategory = category;
      _filteredRecipes = category == 'All'
          ? _allRecipes
          : _allRecipes.where((r) => r.category == category).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: Column(
        children: [
          if (_selectedCategory != 'All')
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(
                    "Category: $_selectedCategory",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: primaryBlue,
                  deleteIcon: const Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.white,
                  ),
                  onDeleted: () => _filterRecipes('All'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide.none,
                ),
              ),
            ),

          Expanded(
            child: _filteredRecipes.isEmpty
                ? Center(
                    child: Text(
                      "No recipes found.",
                      style: GoogleFonts.poppins(color: Colors.blueGrey),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _filteredRecipes.length,
                    itemBuilder: (context, index) {
                      return _buildRecipeCard(_filteredRecipes[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.blueGrey.shade50),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
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
                  top: Radius.circular(24),
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.asset(
                        recipe.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: softBg,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => setState(
                          () => recipe.isFavorite = !recipe.isFavorite,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
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
}

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
