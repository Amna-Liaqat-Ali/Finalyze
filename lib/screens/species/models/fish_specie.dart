import 'package:flutter/material.dart';

class FreshnessIndicator {
  final IconData icon;
  final String title;
  final String detail;
  const FreshnessIndicator({required this.icon, required this.title, required this.detail});
}

class NutritionInfo {
  final String protein;
  final String omega3;
  final String calories;
  final String fat;
  const NutritionInfo({
    required this.protein,
    required this.omega3,
    required this.calories,
    required this.fat,
  });
}

class FishSpecies {
  final String name;       // e.g. "Heera"
  final String urduName;   // e.g. "ہیرا"
  final String category;   // e.g. "Red Snapper"
  final String imagePath;
  final String tip;

  final String scientificName;
  final String region;
  final String season;
  final String marketValue;
  final String habitat;
  final List<FreshnessIndicator> freshnessIndicators;
  final NutritionInfo nutrition;

  FishSpecies({
    required this.name,
    required this.urduName,
    required this.category,
    required this.imagePath,
    required this.tip,
    required this.scientificName,
    required this.region,
    required this.season,
    required this.marketValue,
    required this.habitat,
    required this.freshnessIndicators,
    required this.nutrition,
  });
}
