import 'dart:io';

import 'package:fish_freshness_detection/screens/species/widgets/species_slider.dart';
import 'package:flutter/material.dart';

import '../../utils/image_picker_helper.dart';
import '../../widgets/change_image_sheet.dart';
import '../Blogs/widgets/blog_slider.dart';
import '../Main/analyzing_screen.dart';
import '../history/history_screen.dart';
import 'widgets/action_card.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/image_preview_card.dart';
import 'widgets/scan_card.dart';

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

  void _analyzeFreshness() async {
    if (selectedImage == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AnalyzingScreen(image: selectedImage!)),
    );
    setState(() {
      selectedImage = null;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D2B45), Color(0xFF163E5F), Color(0xFF005C7A)],
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const HomeAppBar(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
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
                              onTap: () {},
                            ),

                      const SizedBox(height: 20),

                      Opacity(
                        opacity: selectedImage != null ? 0.5 : 1.0,
                        child: Row(
                          children: [
                            Expanded(
                              child: ActionCard(
                                icon: Icons.upload,
                                label: "Upload Image",
                                color: Colors.white,
                                onTap: _openGallery,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ActionCard(
                                icon: Icons.history,
                                label: "View History",
                                color: const Color(0xFF74EBD5),
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
                      const SizedBox(height: 20),
                      SpeciesSlider(),

                      SizedBox(height: 20),
                      YouTubeBlogSlider(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
