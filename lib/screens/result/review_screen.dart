import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Main/analyzing_screen.dart';

class ReviewScreen extends StatelessWidget {
  final File? image;
  const ReviewScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D2E5C), Color(0xFF1A5694), Color(0xFF0891B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Cancel',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  // Image preview — takes most of the vertical space
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: image != null
                            ? Image.file(image!, fit: BoxFit.cover)
                            : const Center(
                                child: Icon(Icons.image_not_supported_rounded,
                                    size: 60, color: Colors.grey),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTip(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Sticky bottom action bar
          _buildActionBar(context),
        ],
      ),
    );
  }

  Widget _buildTip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A5694).withOpacity(0.10)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates_rounded,
              color: Color(0xFF2CB88E), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "For best results, center the fish eye or gills and ensure good lighting.",
              style: GoogleFonts.poppins(
                color: const Color(0xFF1A5694),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Retake
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: Text(
                  "Retake",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A5694),
                  side: const BorderSide(color: Color(0xFFDDE3ED), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Analyze
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: image == null
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnalyzingScreen(image: image!),
                          ),
                        ),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: image == null
                          ? [Colors.grey.shade300, Colors.grey.shade400]
                          : const [
                              Color(0xFF0D2E5C),
                              Color(0xFF1565C0),
                              Color(0xFF0891B2),
                              Color(0xFF2CB88E),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: image == null
                        ? []
                        : [
                            BoxShadow(
                              color: const Color(0xFF1565C0).withOpacity(0.30),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.biotech_rounded,
                          color: Colors.white, size: 19),
                      const SizedBox(width: 8),
                      Text(
                        "Analyze",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
