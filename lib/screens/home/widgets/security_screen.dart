import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/screens/services/auth_service.dart';
import '../../../core/app_sizes.dart';
import '../../../core/user_session.dart';
import '../../../widgets/app_toast.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isSaving = false;

  static const _blue = Color(0xFF1A5694);
  static const _teal = Color(0xFF2CB88E);

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  int _strength(String pw) {
    if (pw.isEmpty) return 0;
    int score = 0;
    if (pw.length >= 8) score++;
    if (pw.contains(RegExp(r'[A-Z]'))) score++;
    if (pw.contains(RegExp(r'[0-9]'))) score++;
    if (pw.contains(RegExp(r'[!@#\$%^&*]'))) score++;
    return score;
  }

  Color _strengthColor(int s) {
    switch (s) {
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return _teal;
      default:
        return Colors.grey.shade200;
    }
  }

  String _strengthLabel(int s) {
    switch (s) {
      case 1:
        return "Weak";
      case 2:
        return "Fair";
      case 3:
        return "Good";
      case 4:
        return "Strong";
      default:
        return "";
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final response = await AuthService.changePassword(
        userId: UserSession.userId ?? '',
        currentPassword: _currentPwCtrl.text.trim(),
        newPassword: _newPwCtrl.text.trim(),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        _currentPwCtrl.clear();
        _newPwCtrl.clear();
        _confirmPwCtrl.clear();
        AppToast.success(context, "Password changed successfully");
      } else {
        if (!mounted) return;
        AppToast.error(context, data['message'] ?? "Failed to change password");
      }
    } catch (_) {
      if (!mounted) return;
      AppToast.error(context, "Connection error. Try again.");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = _strength(_newPwCtrl.text);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: _gradientBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(rs(context, 20), rsh(context, 24), rs(context, 20), rsh(context, 40)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel("CHANGE PASSWORD"),
              _buildCard([
                _pwField(
                  label: "Current Password",
                  controller: _currentPwCtrl,
                  show: _showCurrent,
                  onToggle: () => setState(() => _showCurrent = !_showCurrent),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter current password" : null,
                ),
                _fieldDivider(),
                _pwField(
                  label: "New Password",
                  controller: _newPwCtrl,
                  show: _showNew,
                  onToggle: () => setState(() => _showNew = !_showNew),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Enter new password";
                    if (v.length < 8) return "At least 8 characters";
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                if (_newPwCtrl.text.isNotEmpty) _buildStrengthBar(strength),
                _fieldDivider(),
                _pwField(
                  label: "Confirm New Password",
                  controller: _confirmPwCtrl,
                  show: _showConfirm,
                  onToggle: () => setState(() => _showConfirm = !_showConfirm),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Confirm your password";
                    if (v != _newPwCtrl.text) return "Passwords do not match";
                    return null;
                  },
                ),
              ]),
              SizedBox(height: rsh(context, 8)),
              _buildPasswordTip(),
              SizedBox(height: rsh(context, 20)),
              _buildChangePwButton(),
              SizedBox(height: rsh(context, 24)),
              _sectionLabel("ADVANCED"),
              _buildComingSoonNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pwField({
    required String label,
    required TextEditingController controller,
    required bool show,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return Builder(builder: (context) => Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rsh(context, 14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: rs(context, 11),
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey.shade400,
                  letterSpacing: 0.5)),
          SizedBox(height: rsh(context, 8)),
          TextFormField(
            controller: controller,
            obscureText: !show,
            validator: validator,
            onChanged: onChanged,
            style: GoogleFonts.poppins(
                fontSize: rs(context, 14),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A5694)),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_rounded, color: _blue, size: rs(context, 20)),
              suffixIcon: IconButton(
                icon: Icon(
                  show ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Colors.blueGrey.shade300,
                  size: rs(context, 20),
                ),
                onPressed: onToggle,
              ),
              hintText: "••••••••",
              hintStyle:
                  GoogleFonts.poppins(color: Colors.blueGrey.shade200, fontSize: rs(context, 13)),
              filled: true,
              fillColor: const Color(0xFFF4F7FB),
              contentPadding:
                  EdgeInsets.symmetric(vertical: rsh(context, 14), horizontal: rs(context, 16)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                  borderSide: BorderSide(color: _blue.withOpacity(0.4), width: 1.5)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                  borderSide:
                      const BorderSide(color: Colors.redAccent, width: 1.2)),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildStrengthBar(int strength) {
    final color = _strengthColor(strength);
    return Builder(builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(rs(context, 16), 0, rs(context, 16), rsh(context, 12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (i) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 3 ? rs(context, 4) : 0),
                  height: rs(context, 4),
                  decoration: BoxDecoration(
                    color: i < strength ? color : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(rs(context, 2)),
                  ),
                ),
              );
            }),
          ),
          if (strength > 0) ...[
            SizedBox(height: rsh(context, 4)),
            Text(_strengthLabel(strength),
                style: GoogleFonts.poppins(
                    fontSize: rs(context, 11), color: color, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    ));
  }

  Widget _buildPasswordTip() {
    return Builder(builder: (context) => Container(
      padding: EdgeInsets.all(rs(context, 12)),
      decoration: BoxDecoration(
        color: _blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(color: _blue.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_rounded, color: _blue.withOpacity(0.6), size: rs(context, 16)),
          SizedBox(width: rs(context, 8)),
          Expanded(
            child: Text(
              "Use 8+ characters with uppercase letters, numbers and symbols (!@#\$) for a strong password.",
              style: GoogleFonts.poppins(
                  fontSize: rs(context, 11), color: _blue.withOpacity(0.7), height: 1.5),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildComingSoonNote() {
    return Builder(builder: (context) => Container(
      padding: EdgeInsets.all(rs(context, 14)),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.06),
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(color: Colors.orange.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.orange.shade700, size: rs(context, 18)),
          SizedBox(width: rs(context, 10)),
          Expanded(
            child: Text(
              "Biometric login and two-factor authentication (2FA) are not available yet. Only password changes are supported at this time.",
              style: GoogleFonts.poppins(
                  fontSize: rs(context, 11.5), color: Colors.orange.shade800, height: 1.5),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildChangePwButton() {
    return Builder(builder: (context) => GestureDetector(
      onTap: _isSaving ? null : _changePassword,
      child: Container(
        width: double.infinity,
        height: rsh(context, 52),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A5694), Color(0xFF0891B2), Color(0xFF2CB88E)],
          ),
          borderRadius: BorderRadius.circular(rs(context, 15)),
          boxShadow: [
            BoxShadow(
                color: _teal.withOpacity(0.28),
                blurRadius: 14,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Center(
          child: _isSaving
              ? SizedBox(
                  width: rs(context, 20),
                  height: rs(context, 20),
                  child: const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_reset_rounded,
                        color: Colors.white, size: rs(context, 18)),
                    SizedBox(width: rs(context, 8)),
                    Text("Update Password",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: rs(context, 14))),
                  ],
                ),
        ),
      ),
    ));
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _fieldDivider() =>
      Divider(height: 1, indent: 70, endIndent: 16, color: Colors.grey.shade100);

  PreferredSizeWidget _gradientBar(BuildContext context) {
    return AppBar(
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
        icon: Builder(builder: (context) => Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: rs(context, 20))),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Builder(builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: rsh(context, 10), left: rs(context, 4)),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: rs(context, 11),
          fontWeight: FontWeight.w800,
          color: _blue.withOpacity(0.5),
          letterSpacing: 1.4,
        ),
      ),
    ));
  }
}
