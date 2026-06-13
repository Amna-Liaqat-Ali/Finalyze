import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _codeSent = false;
  bool _isSending = false;
  bool _isResetting = false;
  bool _isResending = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _secondsRemaining = 0;
  Timer? _timer;

  static const primaryBlue = Color(0xFF1A5694);

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _sendResetCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Please enter your email address', Colors.orangeAccent);
      return;
    }

    final isResend = _codeSent;
    setState(() {
      _isSending = !isResend;
      _isResending = isResend;
    });

    try {
      final response = await AuthService.forgotPassword(email: email);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() => _codeSent = true);
        _startResendTimer();
        _showMessage(
          data['message'] ?? 'Reset code sent to your email.',
          const Color(0xFF2CB88E),
        );
      } else {
        _showMessage(data['message'] ?? 'Could not send reset code', Colors.redAccent);
      }
    } catch (_) {
      _showMessage('Could not connect to server.', Colors.redAccent);
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _isResending = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (_otpCode.length != 6) {
      _showMessage('Please enter the 6-digit code', Colors.orangeAccent);
      return;
    }
    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters', Colors.orangeAccent);
      return;
    }
    if (password != confirm) {
      _showMessage('Passwords do not match', Colors.orangeAccent);
      return;
    }

    setState(() => _isResetting = true);

    try {
      final response = await AuthService.resetPassword(
        email: email,
        otp: _otpCode,
        newPassword: password,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        _showMessage(
          data['message'] ?? 'Password reset successfully.',
          const Color(0xFF2CB88E),
        );
        Navigator.pop(context);
      } else {
        _showMessage(data['message'] ?? 'Password reset failed', Colors.redAccent);
      }
    } catch (_) {
      _showMessage('Could not connect to server.', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  void _onOtpChanged(int index, String value) {
    if (value.length > 1) {
      _otpControllers[index].text = value.substring(value.length - 1);
    }
    if (value.isNotEmpty && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.85,
              child: Image.asset('assets/images/bg1.jpeg', fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.8],
                  colors: [Colors.transparent, Colors.white.withOpacity(0.6)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: primaryBlue,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'RESET PASSWORD',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: primaryBlue,
                      letterSpacing: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _codeSent ? 'Enter Code' : 'Forgot Password?',
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _codeSent
                        ? 'Enter the code sent to ${_emailController.text.trim()} and choose a new password.'
                        : 'Enter your email and we will send you a reset code.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.blueGrey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.all(24),
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
                            if (!_codeSent) ...[
                              _buildInput(
                                'Email Address',
                                Icons.alternate_email_rounded,
                                _emailController,
                              ),
                              const SizedBox(height: 20),
                              _buildActionButton(
                                label: 'SEND RESET CODE',
                                isLoading: _isSending,
                                onTap: _sendResetCode,
                              ),
                            ] else ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(6, (index) {
                                  return SizedBox(
                                    width: 44,
                                    child: TextField(
                                      controller: _otpControllers[index],
                                      focusNode: _otpFocusNodes[index],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      maxLength: 1,
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: primaryBlue,
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        counterText: '',
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.6),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onChanged: (value) =>
                                          _onOtpChanged(index, value),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 20),
                              _buildInput(
                                'New Password',
                                Icons.lock_outline_rounded,
                                _passwordController,
                                isPassword: true,
                                obscure: _obscurePassword,
                                onToggleObscure: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInput(
                                'Confirm Password',
                                Icons.lock_outline_rounded,
                                _confirmPasswordController,
                                isPassword: true,
                                obscure: _obscureConfirm,
                                onToggleObscure: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildActionButton(
                                label: 'RESET PASSWORD',
                                isLoading: _isResetting,
                                onTap: _resetPassword,
                              ),
                              const SizedBox(height: 12),
                              _secondsRemaining > 0
                                  ? Text(
                                      'Resend code in $_secondsRemaining s',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    )
                                  : TextButton(
                                      onPressed: _isResending ? null : _sendResetCode,
                                      child: _isResending
                                          ? const SizedBox(
                                              height: 16,
                                              width: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              'Resend Code',
                                              style: GoogleFonts.poppins(
                                                color: primaryBlue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscure : false,
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
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: primaryBlue.withOpacity(0.4),
                    size: 18,
                  ),
                  onPressed: onToggleObscure,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: primaryBlue,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
        ),
      ),
    );
  }
}
