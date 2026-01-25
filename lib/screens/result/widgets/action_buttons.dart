import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text("Share"),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download),
            label: const Text(
              "Save Report",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
