import 'package:flutter/material.dart';

// Returns [size]  proportionally to the device's screen width.
double rs(BuildContext context, double size) {
  final w = MediaQuery.sizeOf(context).width;
  return (size * w / 390).clamp(size * 0.78, size * 1.22);
}

double rsh(BuildContext context, double size) {
  final h = MediaQuery.sizeOf(context).height;
  return (size * h / 844).clamp(size * 0.75, size * 1.15);
}

/// Returns a percentage of the screen width (e.g. sw(ctx, 0.5) = 50% of width)
double sw(BuildContext context, double pct) =>
    MediaQuery.sizeOf(context).width * pct;

/// Returns a percentage of the screen height (e.g. sh(ctx, 0.5) = 50% of height)
double sh(BuildContext context, double pct) =>
    MediaQuery.sizeOf(context).height * pct;

/// Alias for rs() — use for font sizes for clarity
double sp(BuildContext context, double size) => rs(context, size);

/// Convenience: raw screen width
double screenWidth(BuildContext context) => MediaQuery.sizeOf(context).width;

/// Convenience: raw screen height
double screenHeight(BuildContext context) => MediaQuery.sizeOf(context).height;
