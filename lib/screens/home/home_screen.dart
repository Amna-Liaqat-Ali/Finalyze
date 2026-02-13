import 'dart:io';

import 'package:Finalyze/screens/species/widgets/species_slider.dart';
import 'package:flutter/material.dart';

import '../../utils/image_picker_helper.dart';
import '../Blogs/widgets/blog_slider.dart';
import '../history/history_screen.dart';
import '../scan/scan_screen.dart';
import 'widgets/action_card.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/scan_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _navigateToReview(File image) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScanScreen(image: image)),
    );
  }

  Future<void> _openCamera() async {
    final image = await ImagePickerHelper.pickFromCamera();
    if (image != null) {
      _navigateToReview(image);
    }
  }

  Future<void> _openGallery() async {
    final image = await ImagePickerHelper.pickFromGallery();
    if (image != null) {
      _navigateToReview(image);
    }
  }

  @override
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
              // 1. APP BAR
              const HomeAppBar(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 15),

                      ScanCard(onScan: _openCamera),

                      const SizedBox(height: 25),

                      Row(
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

                      const SizedBox(height: 20),
                      const SpeciesSlider(),

                      const SizedBox(height: 20),
                      YouTubeBlogSlider(),

                      const SizedBox(height: 50),
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
