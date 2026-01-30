import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/manual_model.dart';
import 'models/step_model.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  List<StepModel> get aiSteps => [
    StepModel(
      icon: Icons.wb_sunny_rounded,
      title: 'Lighting',
      description: 'Use bright, natural light. No shadows.',
      color: const Color(0xFF00E676),
    ),
    StepModel(
      icon: Icons.center_focus_strong_rounded,
      title: 'Focus',
      description: 'Tap to focus. Ensure details are sharp.',
      color: const Color(0xFF00B4D8),
    ),
    StepModel(
      icon: Icons.crop_free_rounded,
      title: 'Framing',
      description: 'Fill the frame. Fish should be centered.',
      color: const Color(0xFFFFAB00),
    ),
    StepModel(
      icon: Icons.cleaning_services_rounded,
      title: 'Clean BG',
      description: 'Place on a plain, solid surface.',
      color: const Color(0xFFFF1744),
    ),
  ];

  List<ManualModel> get manualMethods => [
    ManualModel(
      emoji: '👃',
      method: 'Smell Test',
      description: 'Sea smell is good. Ammonia is bad.',
    ),
    ManualModel(
      emoji: '👀',
      method: 'Clear Eyes',
      description: 'Bulging & clear. Sunken is old.',
    ),
    ManualModel(
      emoji: '🩸',
      method: 'Red Gills',
      description: 'Bright red is fresh. Brown is old.',
    ),
    ManualModel(
      emoji: '✋',
      method: 'Firm Flesh',
      description: 'Bounces back when pressed.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2B45), // Deep Navy Theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2B45),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "SCAN GUIDE",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              24,
              10,
              24,
              100,
            ), // Bottom padding for button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HERO HEADER
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00B4D8).withOpacity(0.2),
                        const Color(0xFF00B4D8).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00B4D8).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Get 100% Accuracy",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Follow these guidelines to ensure the AI detects freshness correctly.",
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF00B4D8),
                        size: 40,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      color: const Color(0xFF00B4D8),
                    ), // Cyan Accent
                    const SizedBox(width: 12),
                    Text(
                      "SCANNING BEST PRACTICES",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. HORIZONTAL STEP CARDS
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: aiSteps.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) =>
                        _StepCard(step: aiSteps[index], number: index + 1),
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      color: const Color(0xFF00E676),
                    ), // Green Accent
                    const SizedBox(width: 12),
                    Text(
                      "MANUAL VERIFICATION",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: manualMethods.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4, // Wider cards
                  ),
                  itemBuilder: (context, index) =>
                      _ManualCard(model: manualMethods[index]),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Text(
                    "Combine AI results with manual checks for safety.",
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final StepModel step;
  final int number;

  const _StepCard({required this.step, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF173652), // Lighter Navy
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(step.icon, color: const Color(0xFF00B4D8), size: 24),
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$number",
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            step.title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            step.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualCard extends StatelessWidget {
  final ManualModel model;

  const _ManualCard({required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF173652), // Lighter Navy
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(model.emoji, style: const TextStyle(fontSize: 24)),
          const Spacer(),
          Text(
            model.method,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            model.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
