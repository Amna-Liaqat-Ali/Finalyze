import 'package:flutter/material.dart';

import '../models/analysis_result_model.dart';
import 'card_wrapper.dart';
import 'detail_row.dart';

class AnalysisDetailsCard extends StatelessWidget {
  final AnalysisResult result;

  const AnalysisDetailsCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(
            icon: Icons.location_on,
            title: "Location",
            value: result.location,
          ),
          const SizedBox(height: 14),
          DetailRow(
            icon: Icons.schedule,
            title: "Estimated Age",
            value: result.estimatedAge,
          ),
        ],
      ),
    );
  }
}
