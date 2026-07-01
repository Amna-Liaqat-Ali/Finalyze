import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../core/app_sizes.dart';

class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: rs(context, 140),
            width: rs(context, 140),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.secondary.withOpacity(0.15),
                ],
              ),
            ),
            child: Icon(icon, size: rs(context, 60), color: AppColors.primary),
          ),
          SizedBox(height: rsh(context, 40)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: rs(context, 26),
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: rsh(context, 16)),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: rs(context, 16),
              color: AppColors.textLight,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
