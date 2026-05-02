import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashLoader extends StatelessWidget {
  final double progress;

  const SplashLoader({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A5694);
    const accentTeal = Color(0xFF2CB88E);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("🐟", style: TextStyle(fontSize: 40)),
        const SizedBox(height: 20),

        Text(
          "${(progress * 100).toInt()}%",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryBlue.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 10),

        Container(
          width: 180,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [accentTeal, Color(0xFF1E88E5)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // 4. SUBTLE SPINNER
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(accentTeal),
            backgroundColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }
}
