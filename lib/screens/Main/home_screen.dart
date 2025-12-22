import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../widgets/custom_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: "Finalyze", showSettings: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            /// Title
            const Text(
              "Fish Freshness Analysis",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            /// Subtitle
            const Text(
              "AI-powered quality detection using image analysis",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textLight),
            ),

            const SizedBox(height: 30),

            /// Upload / Capture Box
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.camera_alt, size: 60, color: AppColors.primary),
                  SizedBox(height: 10),
                  Text(
                    "Tap to select an image for analysis",
                    style: TextStyle(color: AppColors.textLight, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// Input Method Label
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Input Method",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// Camera Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                "Capture Using Camera",
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 15),

            /// Gallery Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.photo_library),
              label: const Text(
                "Select from Gallery",
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 25),

            /// Info Note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "For best results, ensure good lighting and capture a clear view of the fish’s gills and eyes.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
