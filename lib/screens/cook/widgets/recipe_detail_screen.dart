import 'package:flutter/material.dart';

import '../models/recipe.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              background: Image.asset(
                recipe.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.blueGrey),
              ),
            ),
          ),

          // 2. Recipe Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Info Row
                  _buildQuickStats(),
                  const Divider(height: 32),

                  // Ingredients Section
                  _buildSectionTitle('Ingredients'),
                  ...recipe.ingredients.map(
                    (item) => CheckboxListTile(
                      value: false,
                      onChanged: (val) {},
                      title: Text(item),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Instructions Section
                  _buildSectionTitle('Cooking Steps'),
                  ...recipe.instructions.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statColumn(Icons.timer, 'Time', '${recipe.cookTimeMinutes} min'),
        _statColumn(Icons.bolt, 'Difficulty', recipe.difficulty.name),
        _statColumn(Icons.restaurant, 'Style', recipe.category),
      ],
    );
  }

  Widget _statColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
