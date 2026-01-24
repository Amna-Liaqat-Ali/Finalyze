import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class RecentDetectionTile extends StatelessWidget {
  const RecentDetectionTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.set_meal, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Fresh", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("2026-01-24 09:30"),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text("95%", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
