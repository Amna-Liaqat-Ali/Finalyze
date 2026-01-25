import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class ResultHeader extends StatelessWidget {
  final DateTime dateTime;

  const ResultHeader({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      color: AppColors.fresh,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Freshness Result",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${dateTime.year}-${dateTime.month}-${dateTime.day}  ${dateTime.hour}:${dateTime.minute}",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
