import 'package:fish_freshness_detection/screens/result/widgets/status_chips.dart';
import 'package:flutter/material.dart';

import '../models/analysis_result_model.dart';
import 'card_wrapper.dart';
import 'metric_box.dart';

class ResultSummaryCard extends StatelessWidget {
  final AnalysisResult result;

  const ResultSummaryCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
      child: Column(
        children: [
          StatusChip(isFresh: result.isFresh),
          const SizedBox(height: 20),
          Row(
            children: [
              MetricBox(
                value: "${result.freshnessScore}%",
                label: "Freshness Score",
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              MetricBox(
                value: "${result.confidence}%",
                label: "Confidence",
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
