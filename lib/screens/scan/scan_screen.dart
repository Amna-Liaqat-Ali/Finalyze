import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORTS ---
import '../../utils/image_picker_helper.dart';
import '../Main/analyzing_screen.dart'; // Import the Analyze Screen

class ScanScreen extends StatefulWidget {
  final File? image;

  const ScanScreen({super.key, this.image});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _displayImage;
  bool isEnhancing = false;

  @override
  void initState() {
    super.initState();
    _displayImage = widget.image;
  }

  Future<void> _launchCamera() async {
    final pickedFile = await ImagePickerHelper.pickFromCamera();
    if (pickedFile != null) {
      setState(() {
        _displayImage = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_displayImage == null) {
      return _buildEmptyScanState();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            if (widget.image != null && Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              setState(() {
                _displayImage = null;
              });
            }
          },
        ),
        title: Text(
          "Review Capture",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
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
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 1. IMAGE PREVIEW
              Expanded(
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_displayImage!, fit: BoxFit.cover),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          left: 20,
                          child: _glassBadge(Icons.hd_rounded, "High Res"),
                        ),
                        Positioned(
                          top: 20,
                          right: 20,
                          child: _glassBadge(
                            Icons.data_usage_rounded,
                            "2.4 MB",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. TOOLS PANEL (Scrollable)
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2B45).withOpacity(0.8),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quality Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _qualityIndicator(
                              "Lighting",
                              "Good",
                              Colors.greenAccent,
                            ),
                            _verticalDivider(),
                            _qualityIndicator(
                              "Focus",
                              "Sharp",
                              Colors.greenAccent,
                            ),
                            _verticalDivider(),
                            _qualityIndicator(
                              "Glare",
                              "None",
                              Colors.cyanAccent,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        Divider(color: Colors.white.withOpacity(0.1)),
                        const SizedBox(height: 16),

                        // Tools
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _toolButton(Icons.crop_rotate_rounded, "Crop"),
                            _toolButton(Icons.tune_rounded, "Adjust"),
                            _toolButton(
                              Icons.auto_fix_high_rounded,
                              "Enhance",
                              isActive: isEnhancing,
                              onTap: () =>
                                  setState(() => isEnhancing = !isEnhancing),
                            ),
                            _toolButton(
                              Icons.delete_outline_rounded,
                              "Discard",
                              isDestructive: true,
                              onTap: () {
                                if (widget.image != null &&
                                    Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  setState(() => _displayImage = null);
                                }
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Action Buttons
                        Row(
                          children: [
                            // RETAKE BUTTON
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                onPressed: () {
                                  if (widget.image != null &&
                                      Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  } else {
                                    _launchCamera();
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  "Retake",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // ANALYZE BUTTON (Updated)
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF00B4D8),
                                      Color(0xFF0077B6),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00B4D8,
                                      ).withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Navigate to Analyzing Screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AnalyzingScreen(
                                          image: _displayImage!,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.analytics_outlined,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Start Analysis",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets (Same as before)
  Widget _buildEmptyScanState() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2B45),
      body: Center(
        child: GestureDetector(
          onTap: _launchCamera,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF163E5F),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00B4D8).withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 60,
                ),
                const SizedBox(height: 10),
                Text(
                  "Tap to Scan",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassBadge(IconData icon, String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Text(
                text,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qualityIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }

  Widget _verticalDivider() =>
      Container(height: 25, width: 1, color: Colors.white.withOpacity(0.1));

  Widget _toolButton(
    IconData icon,
    String label, {
    bool isDestructive = false,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    final color = isDestructive
        ? Colors.redAccent
        : (isActive ? Colors.cyanAccent : Colors.white);
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.cyanAccent.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? Colors.cyanAccent : Colors.transparent,
              ),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
