import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_back_button.dart';

class AppWaveBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final double height;

  const AppWaveBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
    this.actions = const [],
    this.height = 88,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        height: preferredSize.height + topPad,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D2E5C),
              Color(0xFF1565C0),
              Color(0xFF0891B2),
              Color(0xFF2CB88E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // subtle bubble/depth texture
            Positioned.fill(
              child: Opacity(
                opacity: 0.06,
                child: Image.asset(
                  'assets/images/splash_bg.jpeg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                child: Row(
                  children: [
                    if (showBack)
                      ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: AppBackButton(
                            isGlass: true,
                            onTap: onBack ?? () => Navigator.maybePop(context),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 42),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    if (actions.isNotEmpty)
                      Row(mainAxisSize: MainAxisSize.min, children: actions)
                    else
                      const SizedBox(width: 42),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 22);
    path.quadraticBezierTo(
      size.width * 0.22, size.height - 2,
      size.width * 0.48, size.height - 18,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height - 34,
      size.width, size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper old) => false;
}
