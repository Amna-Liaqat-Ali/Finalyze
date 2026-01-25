import 'dart:io';

import 'package:fish_freshness_detection/screens/result/widgets/action_buttons.dart';
import 'package:fish_freshness_detection/screens/result/widgets/analysis_detail_card.dart';
import 'package:fish_freshness_detection/screens/result/widgets/disclaimer.dart';
import 'package:fish_freshness_detection/screens/result/widgets/recommendation_card.dart';
import 'package:fish_freshness_detection/screens/result/widgets/result_header.dart';
import 'package:fish_freshness_detection/screens/result/widgets/result_summary_card.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import 'models/analysis_result_model.dart';

class ResultScreen extends StatelessWidget {
  final File image;
  final AnalysisResult result;
  final DateTime dateTime;

  const ResultScreen({
    super.key,
    required this.image,
    required this.result,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ResultHeader(dateTime: dateTime),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.file(image, height: 200, fit: BoxFit.cover),
                  const SizedBox(height: 20),

                  ResultSummaryCard(result: result),
                  const SizedBox(height: 20),

                  AnalysisDetailsCard(result: result),
                  const SizedBox(height: 20),

                  const RecommendationCard(),
                  const SizedBox(height: 30),

                  const DisclaimerCard(),
                  const SizedBox(height: 30),

                  const ActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
