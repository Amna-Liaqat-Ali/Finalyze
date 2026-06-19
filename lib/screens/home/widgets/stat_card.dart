import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;

  const StatCard({super.key, required this.label, required this.value});

  static const _primaryBlue = Color(0xFF1A5694);
  static const _teal = Color(0xFF2CB88E);

  double get _progress {
    final clean = value.replaceAll('%', '').trim();
    final n = double.tryParse(clean);
    if (n == null) return 0;
    if (value.contains('%')) return n / 100;
    return (n / 20).clamp(0.0, 1.0); // scale counts to ring
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.27;
    return SizedBox(
      width: size,
      height: size + 28,
      child: Column(
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(size, size),
                  painter: _RingPainter(progress: _progress),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: size * 0.26,
                        fontWeight: FontWeight.bold,
                        color: _primaryBlue,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 6;
    const strokeWidth = 6.5;

    // Track ring
    final trackPaint = Paint()
      ..color = const Color(0xFFE8EDF5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), radius, trackPaint);

    // Progress ring
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFF1A5694), Color(0xFF0891B2), Color(0xFF2CB88E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
