import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../scan/scan_screen.dart';
import 'models/manual_model.dart';
import 'models/step_model.dart';
import 'widgets/animated_item.dart';
import 'widgets/guide_section.dart';
import 'widgets/manual_card.dart';
import 'widgets/step_card.dart';
import 'widgets/tips_card.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  List<StepModel> get aiSteps => [
    StepModel(
      icon: '',
      title: 'Place the Fish',
      description: 'Place the fish on a flat surface with clear visibility.',
    ),
    StepModel(
      icon: '',
      title: 'Ensure Proper Lighting',
      description:
          'Natural or bright lighting gives the most accurate results.',
    ),
    StepModel(
      icon: '',
      title: 'Focus the Camera',
      description: 'Make sure the fish is fully visible and clearly focused.',
    ),
    StepModel(
      icon: '',
      title: 'Use Plain Background',
      description: 'A plain background helps the AI detect features better.',
    ),
    StepModel(
      icon: '',
      title: 'Capture the Image',
      description: 'Tap scan and let the AI analyze the fish freshness.',
    ),
  ];

  List<ManualModel> get manualMethods => [
    ManualModel(
      icon: '👃',
      method: 'Smell',
      description:
          'Fresh fish smells like the sea; sour or ammonia smell is bad.',
    ),
    ManualModel(
      icon: '👀',
      method: 'Eyes',
      description: 'Clear and bulging eyes indicate freshness.',
    ),
    ManualModel(
      icon: '🩸',
      method: 'Gills',
      description: 'Bright red or pink gills are a sign of fresh fish.',
    ),
    ManualModel(
      icon: '✋',
      method: 'Texture',
      description: 'Flesh should be firm and bounce back when pressed.',
    ),
    ManualModel(
      icon: '💧',
      method: 'Slime',
      description: 'Thin slime is normal; thick or sticky slime is not.',
    ),
  ];

  List<String> get tips => [
    'Use natural light whenever possible.',
    'Keep fish on a plain surface for scanning.',
    'Avoid shadows and glare.',
    'Scan immediately after purchase.',
    'Manual checking helps confirm AI results.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GuideAppBar(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// PAGE HEADING
            const Text(
              'How to Scan Fish',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Follow these steps for accurate freshness detection',
              style: TextStyle(fontSize: 13, color: AppColors.textLight),
            ),

            const SizedBox(height: 22),

            GuideSection(
              title: 'AI Scanning Steps',
              child: Column(
                children: List.generate(aiSteps.length, (index) {
                  return AnimatedItem(
                    index: index,
                    child: StepCard(
                      step: aiSteps[index],
                      stepNumber: index + 1,
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 22),

            GuideSection(
              title: 'Manual Checking Methods',
              initiallyExpanded: false,
              child: Column(
                children: List.generate(manualMethods.length, (index) {
                  return AnimatedItem(
                    index: index,
                    child: ManualCard(method: manualMethods[index]),
                  );
                }),
              ),
            ),

            const SizedBox(height: 22),

            GuideSection(
              title: 'Tips & Tricks',
              initiallyExpanded: false,
              child: Column(
                children: List.generate(tips.length, (index) {
                  return AnimatedItem(
                    index: index,
                    child: TipsCard(text: tips[index]),
                  );
                }),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Start Scanning',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuideAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GuideAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: AppColors.textDark,
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline_rounded),
          color: AppColors.textLight,
          onPressed: () {
            // Optional: show guide info / dialog
          },
        ),
        const SizedBox(width: 6),
      ],
    );
  }
}
