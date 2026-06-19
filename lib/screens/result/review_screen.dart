import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/app_back_button.dart';
import '../Main/analyzing_screen.dart';

class ReviewScreen extends StatefulWidget {
  final File? image;
  const ReviewScreen({super.key, required this.image});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _brightnessLevel = 1.0;
  bool _isCropMode = false;
  bool _isEnhanced = false;

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A5694);
    const infoBg = Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _isCropMode ? const Color(0xFF4EE3AA) : Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: AppBackButton(
              isGlass: _isCropMode,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          _isCropMode ? "Crop Mode: Tap to Confirm" : "Review Photo",
          style: GoogleFonts.poppins(
            color: _isCropMode ? Colors.white : primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            _buildImageCard(),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTool(
                  Icons.crop_free,
                  "Crop",
                  isActive: _isCropMode,
                  onTap: () => setState(() => _isCropMode = !_isCropMode),
                ),
                _buildTool(
                  Icons.light_mode_outlined,
                  "Light",
                  isActive: _brightnessLevel > 1.0,
                  onTap: () => setState(
                    () =>
                        _brightnessLevel = _brightnessLevel == 1.0 ? 1.2 : 1.0,
                  ),
                ),
                _buildTool(
                  Icons.auto_fix_high_outlined,
                  "Enhance",
                  isActive: _isEnhanced,
                  onTap: () => setState(() => _isEnhanced = !_isEnhanced),
                ),
              ],
            ),

            const SizedBox(height: 30),

            _buildPrimaryButton(context),

            const SizedBox(height: 12),

            _buildSecondaryButton(context, primaryBlue),

            const SizedBox(height: 25),

            _buildInfoFooter(infoBg, primaryBlue),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard() {
    return GestureDetector(
      onTap: () {
        if (_isCropMode) setState(() => _isCropMode = false);
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.35,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.matrix(_calculateMatrix()),
                child: widget.image != null
                    ? Image.file(widget.image!, fit: BoxFit.contain)
                    : const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
              if (_isCropMode) _buildCropOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4EE3AA), Color(0xFF1E88E5)],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ElevatedButton(
        onPressed: () {
          if (widget.image != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AnalyzingScreen(image: widget.image!),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.biotech_outlined, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "START ANALYSIS",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, Color primaryBlue) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.refresh, size: 20),
        label: const Text("Retake Photo"),
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: BorderSide(color: Colors.grey.shade200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoFooter(Color bg, Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Ready",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: primary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Ensure the fish eye or gills are centered for the most accurate results.",
                  style: GoogleFonts.poppins(
                    color: Colors.blueGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropOverlay() {
    return Container(
      margin: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4EE3AA), width: 3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          _corner(0, 0, 0),
          _corner(0, null, 1.57, right: 0),
          _corner(null, 0, 4.71, left: 0),
          _corner(null, 0, 3.14, right: 0),
        ],
      ),
    );
  }

  List<double> _calculateMatrix() {
    double brightness = _brightnessLevel;
    double saturation = _isEnhanced ? 1.4 : 1.0;
    double contrast = _isEnhanced ? 1.2 : 1.0;
    return [
      contrast * brightness,
      0,
      0,
      0,
      0,
      0,
      contrast * brightness,
      0,
      0,
      0,
      0,
      0,
      contrast * brightness,
      0,
      0,
      0,
      0,
      0,
      saturation,
      0,
    ];
  }

  Widget _buildTool(
    IconData icon,
    String label, {
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF4EE3AA).withOpacity(0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? const Color(0xFF4EE3AA)
                    : Colors.grey.shade200,
              ),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? const Color(0xFF2CB88E)
                  : const Color(0xFF1A5694),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF2CB88E) : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner(
    double? top,
    double? bottom,
    double rotation, {
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFF4EE3AA), width: 4),
              left: BorderSide(color: Color(0xFF4EE3AA), width: 4),
            ),
          ),
        ),
      ),
    );
  }
}
