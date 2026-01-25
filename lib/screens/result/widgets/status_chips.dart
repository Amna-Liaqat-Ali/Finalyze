import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class StatusChip extends StatelessWidget {
  final bool isFresh;

  const StatusChip({super.key, required this.isFresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: isFresh
            ? AppColors.success.withOpacity(0.15)
            : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        isFresh ? "✔ Fresh" : "✖ Not Fresh",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isFresh ? AppColors.success : Colors.red,
        ),
      ),
    );
  }
}
