import 'package:flutter/material.dart';

class DisclaimerCard extends StatelessWidget {
  const DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        "⚠ Always follow food safety practices. This is an AI-assisted analysis.",
        style: TextStyle(fontSize: 13),
      ),
    );
  }
}
