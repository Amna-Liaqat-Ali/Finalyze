import 'package:fish_freshness_detection/constants/colors.dart';
import 'package:fish_freshness_detection/screens/cook/data/recipe_data.dart';
import 'package:fish_freshness_detection/screens/cook/widgets/recipe_detail_screen.dart';
import 'package:flutter/material.dart';

import 'models/recipe.dart';

class RecipeScreen extends StatefulWidget {
  @override
  _RecipeScreenState createState() => _RecipeScreenState();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Fish Recipes",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.primary),
            onPressed: () {
              showSearch(
                context: context,
                delegate: RecipeSearchDelegate(allRecipes: _allRecipes),
              );
            },
          ),
          // Category Dropdown Filter
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: AppColors.primary),
            onSelected: _filterRecipes,
            itemBuilder: (context) => _categories.map((String category) {
              return PopupMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Active Filter Badge
          if (_selectedCategory != 'All')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(
                    _selectedCategory,
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.blueAccent,
                  onDeleted: () => _filterRecipes('All'),
                  deleteIconColor: Colors.white,
                ),
              ),
            ),

          Expanded(
            child: _filteredRecipes.isEmpty
                ? Center(child: Text("No recipes found for this category."))
                : ListView.builder(
                    padding: EdgeInsets.all(16),
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

    return Card(
      margin: EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: isAsset
                  ? Image.asset(
                      recipe.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Icon(Icons.broken_image),
                    )
                  : Image.network(
                      recipe.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Icon(Icons.broken_image),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        recipe.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          recipe.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () => setState(
                          () => recipe.isFavorite = !recipe.isFavorite,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('${recipe.cookTimeMinutes} min'),
                      SizedBox(width: 15),
                      Icon(Icons.flash_on, size: 16, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(recipe.difficulty.name.toUpperCase()),
                      Spacer(),
                      _buildSpiceLevel(recipe.spiceLevel),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpiceLevel(int level) {
    return Row(
      children: List.generate(
        3,
        (i) => Icon(
          Icons.whatshot,
          size: 16,
          color: i < level ? Colors.red : Colors.grey[300],
        ),
      ),
    );
  }
}

class RecipeSearchDelegate extends SearchDelegate {
  final List<Recipe> allRecipes;
  RecipeSearchDelegate({required this.allRecipes});

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: Icon(Icons.arrow_back),
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
        title: Text(results[index].title),
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
