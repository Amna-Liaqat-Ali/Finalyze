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
