import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Ensure these imports are correct for your project structure
import 'data/recipe_data.dart';
import 'models/recipe.dart';
import 'widgets/recipe_detail_screen.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
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
      backgroundColor: const Color(0xFF0D2B45), // Deep Navy Theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2B45),
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Fish Recipes",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: RecipeSearchDelegate(allRecipes: _allRecipes),
              );
            },
          ),
          // Category Filter Popup
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Color(0xFF00B4D8)),
            color: const Color(0xFF173652), // Dark Menu Background
            onSelected: _filterRecipes,
            itemBuilder: (context) => _categories.map((String category) {
              return PopupMenuItem<String>(
                value: category,
                child: Text(
                  category,
                  style: GoogleFonts.inter(color: Colors.white),
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Active Filter Badge
          if (_selectedCategory != 'All')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(
                    "Category: $_selectedCategory",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: const Color(0xFF00B4D8),
                  deleteIcon: const Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.white,
                  ),
                  onDeleted: () => _filterRecipes('All'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

          Expanded(
            child: _filteredRecipes.isEmpty
                ? Center(
                    child: Text(
                      "No recipes found.",
                      style: GoogleFonts.inter(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
    bool isAsset = recipe.imageUrl.startsWith('assets/');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF173652), // Lighter Navy Slate
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: isAsset
                      ? Image.asset(
                          recipe.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                            ),
                          ),
                        )
                      : Image.network(
                          recipe.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                ),
              ),

              // Info Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            recipe.title,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(
                            () => recipe.isFavorite = !recipe.isFavorite,
                          ),
                          child: Icon(
                            recipe.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: const Color(0xFFFF1744), // Accent Red
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Time
                        const Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: Color(0xFF00B4D8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.cookTimeMinutes} min',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Difficulty
                        const Icon(
                          Icons.bar_chart_rounded,
                          size: 16,
                          color: Color(0xFF00E676),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.difficulty.name.toUpperCase(),
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const Spacer(),

                        // Spiciness
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

  Widget _buildSpiceLevel(int level) {
    return Row(
      children: List.generate(
        3,
        (i) => Icon(
          Icons.whatshot_rounded,
          size: 16,
          color: i < level
              ? const Color(0xFFFFAB00) // Amber for spice
              : Colors.white12,
        ),
      ),
    );
  }
}

// --- SEARCH DELEGATE (Dark Theme) ---
class RecipeSearchDelegate extends SearchDelegate {
  final List<Recipe> allRecipes;
  RecipeSearchDelegate({required this.allRecipes});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D2B45),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(titleLarge: TextStyle(color: Colors.white)),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
      scaffoldBackgroundColor: const Color(0xFF0D2B45),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
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

    return Container(
      color: const Color(0xFF0D2B45), // Deep Navy Background
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            results[index].title,
            style: GoogleFonts.inter(color: Colors.white),
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
      ),
    );
  }
}
