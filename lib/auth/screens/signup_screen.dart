import 'dart:convert';
import 'dart:ui';

import 'package:Finalyze/auth/screens/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onLoginTap;

  const RegisterScreen({
    super.key,
    required this.onBack,
    required this.onLoginTap,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  static const primaryBlue = Color(0xFF1A5694);

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in all fields", Colors.orangeAccent);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.register(name, email, password);

      if (response.statusCode == 201) {
        _showSnackBar(
          "Registration successful! Please login.",
          const Color(0xFF2CB88E), // Project Teal
        );
        Future.delayed(const Duration(seconds: 1), () => widget.onLoginTap());
      } else {
        final data = jsonDecode(response.body);
        _showSnackBar(
          data['message'] ?? "Registration failed",
          Colors.redAccent,
        );
      }
    } catch (e) {
      _showSnackBar(
        "Connection error. Is your server running?",
        Colors.redAccent,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.85,
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
                      stops: const [0.0, 0.8],
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.6),
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
                      _buildBackButton(widget.onBack),
                      const Spacer(flex: 1),

                      Text(
                        "NEW MEMBER",
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: primaryBlue,
                          letterSpacing: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Create\nAccount",
                        style: GoogleFonts.poppins(
                          fontSize: 42,
                          color: primaryBlue,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 30),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildLightInput(
                                  "Full Name",
                                  Icons.person_outline_rounded,
                                  _nameController,
                                ),
                                const SizedBox(height: 20),
                                _buildLightInput(
                                  "Email Address",
                                  Icons.alternate_email_rounded,
                                  _emailController,
                                ),
                                const SizedBox(height: 20),
                                _buildLightInput(
                                  "Password",
                                  Icons.fingerprint_rounded,
                                  _passwordController,
                                  isPassword: true,
                                ),
                                const SizedBox(height: 30),

                                InkWell(
                                  onTap: _isLoading ? null : _handleRegister,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: double.infinity,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: primaryBlue,
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryBlue.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              "Register",
                                              style: GoogleFonts.lexend(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 2,
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

                      const Spacer(flex: 2),
                      Center(
                        child: TextButton(
                          onPressed: widget.onLoginTap,
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 13,
                              ),
                              children: const [
                                TextSpan(
                                  text: "Login",
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  Widget _buildLightInput(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: primaryBlue, fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          hintText: hint,
          hintStyle: TextStyle(color: primaryBlue.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: primaryBlue.withOpacity(0.7), size: 20),
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
          color: Colors.white.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: const Icon(Icons.arrow_back, color: primaryBlue, size: 20),
      ),
    );
  }
}
