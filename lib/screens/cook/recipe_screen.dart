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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Fish Recipes",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Category Selector
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedCategory == _categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ChoiceChip(
                    label: Text(_categories[index]),
                    selected: isSelected,
                    selectedColor: Colors.blueAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    onSelected: (val) => _filterRecipes(_categories[index]),
                  ),
                );
              },
            ),
          ),
          // Recipe List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _filteredRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _filteredRecipes[index];
                return _buildRecipeCard(recipe);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Column(
        children: [
          Image.asset(
            recipe.imageUrl,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 180,
                color: Colors.grey[300],
                child: Icon(Icons.broken_image, size: 50),
              );
            },
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
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: StadiumBorder(),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailScreen(recipe: recipe),
                        ),
                      );
                    },
                    child: Text(
                      "View Detail Recipe (English)",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
