enum Difficulty { easy, medium, hard }

class Recipe {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final int cookTimeMinutes;
  final Difficulty difficulty;
  final int spiceLevel;
  final List<String> ingredients;
  final List<String> instructions;
  // 'fresh', 'moderate' — spoiled fish is never recommended
  final List<String> suitableFor;
  bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.cookTimeMinutes,
    required this.difficulty,
    required this.spiceLevel,
    required this.ingredients,
    required this.instructions,
    this.suitableFor = const ['fresh', 'moderate'],
    this.isFavorite = false,
  });
}
