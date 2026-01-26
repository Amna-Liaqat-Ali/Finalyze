import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../models/scan_history_model.dart';

class StatusBadge extends StatelessWidget {
  final ScanStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late String text;

    switch (status) {
      case ScanStatus.fresh:
        color = AppColors.success;
        text = "Fresh";
        break;
      case ScanStatus.moderate:
        color = Colors.orange;
        text = "Moderate";
        break;
      case ScanStatus.fair:
        color = Colors.deepOrange;
        text = "Fair";
        break;
      case ScanStatus.spoiled:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
