import 'package:flutter/material.dart';

import '../constants/colors.dart';

class StatusBadge extends StatelessWidget {
  final bool isFresh;

  const StatusBadge({super.key, required this.isFresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFresh ? AppColors.fresh : AppColors.spoiled,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isFresh ? "FRESH" : "SPOILED",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
