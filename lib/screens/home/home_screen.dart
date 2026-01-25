import 'dart:io';

import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../utils/image_picker_helper.dart';
import '../Main/history_screen.dart';
import 'widgets/action_card.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/recent_detection_tile.dart';
import 'widgets/scan_card.dart';
import 'widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? selectedImage;

  Future<void> _openCamera() async {
    final image = await ImagePickerHelper.pickFromCamera();
    if (image != null) {
      setState(() => selectedImage = image);
    }
  }

  Future<void> _openGallery() async {
    final image = await ImagePickerHelper.pickFromGallery();
    if (image != null) {
      setState(() => selectedImage = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HomeAppBar(),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Expanded(
                        child: StatCard(
                          value: "1247",
                          label: "Total Scans",
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: StatCard(
                          value: "25",
                          label: "Fresh Today",
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  ScanCard(onScan: _openCamera),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ActionCard(
                          icon: Icons.upload,
                          label: "Upload Image",
                          color: AppColors.primary,
                          onTap: _openGallery,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ActionCard(
                          icon: Icons.history,
                          label: "View History",
                          color: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HistoryScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Recent Detections",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  RecentDetectionTile(
                    isFresh: true,
                    confidence: 95,
                    time: "Today 09:30",
                  ),
                  RecentDetectionTile(
                    isFresh: false,
                    confidence: 35,
                    time: "Today 06:00",
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
