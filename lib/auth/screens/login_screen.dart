import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_sizes.dart';
import '../../auth/screens/forgot_password_screen.dart';
import '../../auth/screens/otp_verification_screen.dart';
import '../../auth/screens/services/auth_service.dart';
import '../../core/user_session.dart';
import '../../screens/Main/MainScreen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_toast.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onRegisterTap;

  const LoginScreen({
    super.key,
    required this.onBack,
    required this.onRegisterTap,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showSuccess = false;

  static const primaryBlue = Color(0xFF1A5694);

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      AppToast.warning(context, "Please enter both email and password");
      return;
    }
    final emailRegex = RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      AppToast.warning(context, "Please enter a valid email address");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.login(email, password);
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        await UserSession.initialize(
          id: data['userId'].toString(),
          userToken: data['token'].toString(),
          userName: data['fullName']?.toString() ?? data['name']?.toString(),
          userEmail: email,
        );

        if (!mounted) return;
        setState(() => _showSuccess = true);
      } else if (response.statusCode == 403 &&
          data['requiresVerification'] == true) {
        if (!mounted) return;

        AppToast.warning(context,
            data['message'] ?? 'Please verify your email with the OTP sent.');

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              email: data['email']?.toString() ?? email,
            ),
          ),
        );
      } else {
        if (mounted) AppToast.error(context, data['message'] ?? "Invalid credentials");
      }
    } catch (e) {
      if (mounted) AppToast.error(context, "Could not connect to server. Check your network.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        SingleChildScrollView(
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
                  padding: EdgeInsets.symmetric(horizontal: rs(context, 24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: rsh(context, 20)),
                      _buildBackButton(widget.onBack),

                      const Spacer(flex: 1),

                      Text(
                        "FINALYZE",
                        style: GoogleFonts.lexend(
                          fontSize: rs(context, 13),
                          color: primaryBlue,
                          letterSpacing: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: rsh(context, 8)),
                      Text(
                        "Verify\nFreshness",
                        style: GoogleFonts.poppins(
                          fontSize: rs(context, 38),
                          color: primaryBlue,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),

                      SizedBox(height: rsh(context, 32)),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: EdgeInsets.all(rs(context, 24)),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(
                                0.3,
                              ), // Lowered opacity
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildLightInput(
                                  "Email Address",
                                  Icons.alternate_email_rounded,
                                  _emailController,
                                ),
                                SizedBox(height: rsh(context, 16)),
                                _buildLightInput(
                                  "Password",
                                  Icons.fingerprint_rounded,
                                  _passwordController,
                                  isPassword: true,
                                ),
                                SizedBox(height: rsh(context, 6)),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ForgotPasswordScreen(
                                            initialEmail: _emailController.text
                                                .trim(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Forgot password?',
                                      style: GoogleFonts.poppins(
                                        color: primaryBlue,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: rsh(context, 14)),

                                InkWell(
                                  onTap: _isLoading ? null : _handleLogin,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: double.infinity,
                                    height: rsh(context, 52),
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
                                              "Login",
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
                          onPressed: widget.onRegisterTap,
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: rs(context, 13),
                              ),
                              children: const [
                                TextSpan(
                                  text: "Register",
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
        if (_showSuccess)
          Positioned.fill(
            child: LoginSuccessOverlay(
              onComplete: () async {
                if (!mounted) return;
                final uid = UserSession.userId ?? '';
                final prefs = await SharedPreferences.getInstance();
                final seenKey = 'onboarding_seen_$uid';
                final hasSeenOnboarding = prefs.getBool(seenKey) ?? false;

                Widget destination;
                if (!hasSeenOnboarding) {
                  await prefs.setBool(seenKey, true);
                  destination = const OnboardingScreen();
                } else {
                  destination = const MainScreen();
                }

                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (_, a, __) => destination,
                    transitionsBuilder: (_, a, __, child) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0, 0.06),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic));
                      return FadeTransition(
                        opacity: a,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 550),
                  ),
                  (_) => false,
                );
              },
            ),
          ),
      ]),
    );
  }

  Widget _buildBackButton(VoidCallback onTap) {
    return AppBackButton(isGlass: true, onTap: onTap);
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
        obscureText: isPassword ? _obscurePassword : false,
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
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: primaryBlue.withOpacity(0.4),
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
        ),
      ),
    );
  }
}
