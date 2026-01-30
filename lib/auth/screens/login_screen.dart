import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onRegisterTap;

  const LoginScreen({
    super.key,
    required this.onBack,
    required this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05111A),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // 1. Background Image
              Positioned.fill(
                child: Opacity(
                  opacity: 0.6,
                  child: Image.asset(
                    'assets/images/bg1.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        const Color(0xFF05111A).withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildBackButton(onBack),

                      const Spacer(flex: 1),

                      Text(
                        "FINALYZE",
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: Colors.cyanAccent,
                          letterSpacing: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Verify\nFreshness",
                        style: GoogleFonts.poppins(
                          fontSize: 42,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),

                      const SizedBox(height: 40),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D2B45).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.cyanAccent.withOpacity(0.15),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildDarkInput(
                                  "Email Address",
                                  Icons.alternate_email_rounded,
                                ),
                                const SizedBox(height: 20),
                                _buildDarkInput(
                                  "Password",
                                  Icons.fingerprint_rounded,
                                  isPassword: true,
                                ),

                                const SizedBox(height: 30),

                                Container(
                                  width: double.infinity,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white.withOpacity(0.05),
                                    border: Border.all(
                                      color: Colors.cyanAccent.withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(
                                          0.15,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {},
                                      splashColor: Colors.cyanAccent
                                          .withOpacity(0.2),
                                      highlightColor: Colors.cyanAccent
                                          .withOpacity(0.1),
                                      child: Center(
                                        child: Text(
                                          "Login",
                                          style: GoogleFonts.lexend(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.cyanAccent,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "Or continue with",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(Icons.g_mobiledata), // Google
                          const SizedBox(width: 20),
                          _buildSocialButton(Icons.apple), // Apple
                          const SizedBox(width: 20),
                          _buildSocialButton(Icons.facebook), // Facebook
                        ],
                      ),

                      const Spacer(flex: 2),

                      Center(
                        child: Column(
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                "Recover Credentials",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: onRegisterTap,
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 12,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Register",
                                      style: TextStyle(
                                        color: Colors.cyanAccent.withOpacity(
                                          0.8,
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
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

  Widget _buildBackButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () {},
          splashColor: Colors.cyanAccent.withOpacity(0.1),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildDarkInput(
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: TextField(
            obscureText: isPassword,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              prefixIcon: Icon(
                icon,
                color: Colors.white.withOpacity(0.6),
                size: 20,
              ),
              suffixIcon: isPassword
                  ? Icon(
                      Icons.remove_red_eye_outlined,
                      color: Colors.white.withOpacity(0.2),
                      size: 18,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
