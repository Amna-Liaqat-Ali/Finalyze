import 'package:flutter/material.dart';

class AppColors {
  // Splash Gradient
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E5FA3), Color(0xFF2BB0E6), Color(0xFF2ECC9A)],
  );
  static const Color accentGreen = Color(0xFFB6E700);
  // Splash-based theme
  static const Color primary = Color(0xFF1E5FA3);
  static const Color secondary = Color(0xFF2ECC9A);
  static const Color accent = Color(0xFF2BB0E6);

  static const Color background = Color(0xFFF5FAFF);
  static const Color card = Colors.white;

  static const Color textDark = Color(0xFF1C1C1C);
  static const Color textLight = Color(0xFF7A8A99);

  static const fresh = Color(0xFF4CAF50);
  static const spoiled = Color(0xFFE53935);

  static const blue = Color(0xFF2563EB);
  static const teal = Color(0xFF0891B2);

  static const white = Colors.white;
  static const success = Color(0xFF22C55E);
}
