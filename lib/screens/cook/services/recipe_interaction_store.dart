import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';

class RecipeInteractionStore {
  static const _favPrefix = 'fav_recipe_';
  static const _ratingPrefix = 'rating_recipe_';

  /// Loads persisted favorite/rating state into each [Recipe] in place.
  static Future<void> hydrate(List<Recipe> recipes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final recipe in recipes) {
        recipe.isFavorite = prefs.getBool('$_favPrefix${recipe.id}') ?? recipe.isFavorite;
        recipe.rating = prefs.getDouble('$_ratingPrefix${recipe.id}') ?? recipe.rating;
      }
    } catch (e) {
      debugPrint('[RecipeInteractionStore] hydrate error: $e');
    }
  }

  static Future<void> setFavorite(String id, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_favPrefix$id', value);
    } catch (e) {
      debugPrint('[RecipeInteractionStore] setFavorite error: $e');
    }
  }

  static Future<void> setRating(String id, double value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('$_ratingPrefix$id', value);
    } catch (e) {
      debugPrint('[RecipeInteractionStore] setRating error: $e');
    }
  }
}
