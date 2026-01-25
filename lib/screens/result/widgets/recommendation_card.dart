import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import 'bullet_point.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.success.withOpacity(0.4)),
        color: AppColors.success.withOpacity(0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Recommendations",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          SizedBox(height: 12),
          BulletPoint("Excellent for raw consumption (sushi, sashimi)"),
          BulletPoint("Store at 0–4°C and use within 24 hours"),
          BulletPoint("Safe for all cooking methods"),
        ],
      ),
    );
  }
}
