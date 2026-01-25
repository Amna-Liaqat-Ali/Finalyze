import 'dart:io';

import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../utils/image_picker_helper.dart';
import '../../widgets/change_image_sheet.dart';
import '../Main/analyzing_screen.dart';
import '../Main/history_screen.dart';
import 'widgets/action_card.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/image_preview_card.dart';
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
      setState(() {
        selectedImage = image;
      });
    }
  }

  Future<void> _openGallery() async {
    final image = await ImagePickerHelper.pickFromGallery();
    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  void _showChangeImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return ChangeImageSheet(
          onCamera: () async {
            Navigator.pop(context);
            final image = await ImagePickerHelper.pickFromCamera();
            if (image != null) {
              setState(() => selectedImage = image);
            }
          },
          onGallery: () async {
            Navigator.pop(context);
            final image = await ImagePickerHelper.pickFromGallery();
            if (image != null) {
              setState(() => selectedImage = image);
            }
          },
        );
      },
    );
  }

  void _analyzeFreshness() {
    if (selectedImage == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AnalyzingScreen(image: selectedImage!)),
    );
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
                  // Stats Row
                  Opacity(
                    opacity: selectedImage != null
                        ? 0.5
                        : 1.0, // fade if image selected
                    child: Row(
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
                  ),

                  const SizedBox(height: 25),

                  selectedImage == null
                      ? ScanCard(onScan: _openCamera)
                      : ImagePreviewCard(
                          image: selectedImage!,
                          onAnalyze: _analyzeFreshness,
                          onChange: _showChangeImageOptions,
                          onRemove: () {
                            setState(() {
                              selectedImage = null;
                            });
                          },
                        ),

                  const SizedBox(height: 20),

                  Opacity(
                    opacity: selectedImage != null
                        ? 0.5
                        : 1.0, // fade if image is selected
                    child: Row(
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
                  ),

                  const SizedBox(height: 25),

                  Opacity(
                    opacity: selectedImage != null ? 0.5 : 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Recent Detection",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 12),
                        RecentDetectionTile(
                          isFresh: true,
                          confidence: 95,
                          time: "Today 09:30",
                        ),
                      ],
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
