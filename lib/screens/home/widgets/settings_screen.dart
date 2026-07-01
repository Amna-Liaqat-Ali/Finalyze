import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/screens/services/auth_service.dart';
import '../../../auth/screens/welcome_screen.dart';
import '../../../core/app_sizes.dart';
import '../../../core/user_session.dart';
import '../../history/history_screen.dart';
import '../../premium/premium_screen.dart';
import 'account_screen.dart';
import 'security_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _enhancedAnalysis = true;
  bool _notifications = true;
  bool _isPremium = false;

  static const _blue = Color(0xFF1A5694);
  static const _teal = Color(0xFF2CB88E);
  static const _ocean = Color(0xFF0891B2);

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPremium = prefs.getBool('is_premium') ?? false;
    });
  }

  Future<void> _pickImage() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _profileImage = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(rs(context, 20), rsh(context, 24), rs(context, 20), rsh(context, 40)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Premium banner
                  _buildPremiumCard(),
                  SizedBox(height: rsh(context, 24)),

                  _sectionLabel("ACCOUNT"),
                  _buildCard([
                    _tile(
                      icon: Icons.person_rounded,
                      iconColor: _blue,
                      title: "Edit Profile",
                      subtitle: "Update your name and email",
                      onTap: () => _push(const AccountDetailsScreen()),
                    ),
                    _divider(),
                    _tile(
                      icon: Icons.lock_rounded,
                      iconColor: _ocean,
                      title: "Security & Password",
                      subtitle: "Password, biometrics, 2FA",
                      onTap: () => _push(const SecurityScreen()),
                    ),
                  ]),
                  SizedBox(height: rsh(context, 20)),

                  _sectionLabel("PREFERENCES"),
                  _buildCard([
                    _switchTile(
                      icon: Icons.psychology_rounded,
                      iconColor: _teal,
                      title: "Enhanced AI Analysis",
                      subtitle: "High-detail freshness detection",
                      value: _enhancedAnalysis,
                      onChanged: (v) => setState(() => _enhancedAnalysis = v),
                    ),
                    _divider(),
                    _switchTile(
                      icon: Icons.notifications_rounded,
                      iconColor: _blue,
                      title: "Scan Notifications",
                      subtitle: "Alerts when analysis completes",
                      value: _notifications,
                      onChanged: (v) => setState(() => _notifications = v),
                    ),
                  ]),
                  SizedBox(height: rsh(context, 20)),

                  _sectionLabel("HISTORY"),
                  _buildCard([
                    _tile(
                      icon: Icons.history_rounded,
                      iconColor: _teal,
                      title: "Scan History",
                      subtitle: "View all your past scans",
                      onTap: () => _push(
                          HistoryScreen(userId: UserSession.userId ?? '')),
                    ),
                  ]),
                  SizedBox(height: rsh(context, 20)),

                  _sectionLabel("DANGER ZONE"),
                  _buildCard([
                    _tile(
                      icon: Icons.delete_forever_rounded,
                      iconColor: Colors.redAccent,
                      title: "Delete Account",
                      subtitle: "Permanently remove your account and data",
                      onTap: _confirmDeleteAccount,
                    ),
                  ]),
                  SizedBox(height: rsh(context, 28)),

                  _buildSignOut(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header with wave + profile ────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final displayName = (UserSession.name?.isNotEmpty == true)
        ? UserSession.name!
        : (UserSession.email?.isNotEmpty == true
            ? UserSession.email!.split('@').first
            : 'My Account');

    return ClipPath(
      clipper: _WaveClipper(),
      child: SizedBox(
        height: rsh(context, 220) + topPad,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ocean background image — matches home header
            Image.asset(
              'assets/images/splash_bg.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            // Dark gradient overlay — same palette as home
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0D2E5C).withOpacity(0.82),
                    const Color(0xFF0D47A1).withOpacity(0.70),
                    const Color(0xFF006994).withOpacity(0.60),
                    const Color(0xFF00897B).withOpacity(0.55),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Content
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Back button row
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: rs(context, 20)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Avatar + name
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: rs(context, 80),
                          height: rs(context, 80),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 14,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _profileImage != null
                                ? Image.file(_profileImage!, fit: BoxFit.cover)
                                : Container(
                                    color: Colors.white.withOpacity(0.15),
                                    child: Icon(Icons.person_rounded,
                                        color: Colors.white70, size: rs(context, 42)),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: rs(context, 24),
                            height: rs(context, 24),
                            decoration: BoxDecoration(
                              color: _teal,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: rs(context, 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: rsh(context, 10)),
                  Text(
                    displayName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: rs(context, 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (UserSession.email?.isNotEmpty == true)
                    Text(
                      UserSession.email!,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.68),
                        fontSize: rs(context, 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Premium card ──────────────────────────────────────────────────────────

  Widget _buildPremiumCard() {
    return Builder(builder: (context) => GestureDetector(
      onTap: () => _push(const PremiumScreen(standalone: true)),
      child: Container(
        padding: EdgeInsets.all(rs(context, 18)),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D2E5C), Color(0xFF0891B2), Color(0xFF2CB88E)],
          ),
          borderRadius: BorderRadius.circular(rs(context, 20)),
          boxShadow: [
            BoxShadow(
              color: _ocean.withOpacity(0.30),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: rs(context, 46),
              height: rs(context, 46),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.workspace_premium_rounded,
                  color: Colors.white, size: rs(context, 24)),
            ),
            SizedBox(width: rs(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_isPremium ? "Premium Active" : "Unlock Premium",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: rs(context, 14))),
                  Text(_isPremium ? "You have unlimited access" : "Unlimited scans + full AI power",
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: rs(context, 11))),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 14), vertical: rsh(context, 7)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rs(context, 20)),
              ),
              child: Text(_isPremium ? "View" : "Upgrade",
                  style: GoogleFonts.poppins(
                      color: _blue,
                      fontWeight: FontWeight.bold,
                      fontSize: rs(context, 12))),
            ),
          ],
        ),
      ),
    ));
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Builder(builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: rsh(context, 10), left: rs(context, 4)),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: rs(context, 11),
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1A5694),
          letterSpacing: 1.4,
        ),
      ),
    ));
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.shade50),
      ),
      child: Column(children: children),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Builder(builder: (context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rs(context, 18)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rsh(context, 14)),
        child: Row(
          children: [
            Container(
              width: rs(context, 40),
              height: rs(context, 40),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(rs(context, 12)),
              ),
              child: Icon(icon, color: iconColor, size: rs(context, 20)),
            ),
            SizedBox(width: rs(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: rs(context, 14),
                          color: const Color(0xFF1A5694))),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: rs(context, 11),
                          color: const Color(0xFF1A5694).withOpacity(0.45))),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(Icons.arrow_forward_ios_rounded,
                        size: rs(context, 13), color: const Color(0xFF1A5694).withOpacity(0.3))
                    : const SizedBox()),
          ],
        ),
      ),
    ));
  }

  Widget _switchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Builder(builder: (context) => Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rsh(context, 12)),
      child: Row(
        children: [
          Container(
            width: rs(context, 40),
            height: rs(context, 40),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(rs(context, 12)),
            ),
            child: Icon(icon, color: iconColor, size: rs(context, 20)),
          ),
          SizedBox(width: rs(context, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: rs(context, 14),
                        color: const Color(0xFF1A5694))),
                Text(subtitle,
                    style: GoogleFonts.poppins(
                        fontSize: rs(context, 11), color: const Color(0xFF1A5694).withOpacity(0.45))),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: _teal,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    ));
  }

  Widget _divider() => Divider(
      height: 1,
      indent: 70,
      endIndent: 16,
      color: Colors.blue.shade50);

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Delete Account",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.redAccent)),
        content: Text(
          "This will permanently delete your account and all scan history. This action cannot be undone.",
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.blueGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Delete",
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final uid = UserSession.userId ?? '';
    try {
      final response = await AuthService.deleteAccount(uid);
      if (response.statusCode == 200) {
        await UserSession.clear();
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
          (route) => false,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to delete account. Try again.")),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Connection error. Try again.")),
        );
      }
    }
  }

  Widget _buildSignOut() {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Sign Out",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A5694))),
            content: Text("Are you sure you want to sign out?",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text("Cancel",
                    style: GoogleFonts.poppins(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text("Sign Out",
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await UserSession.clear();
          // Reset premium state so it shows again on next login
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('premium_seen');
          await prefs.remove('is_premium');
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthWrapper()),
            (route) => false,
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: rsh(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rs(context, 18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent, size: rs(context, 20)),
            SizedBox(width: rs(context, 10)),
            Text("Sign Out",
                style: GoogleFonts.poppins(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: rs(context, 15))),
          ],
        ),
      ),
    );
  }

  void _push(Widget screen) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => screen));

}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.5, size.height - 18);
    path.quadraticBezierTo(
        size.width * 0.75, size.height - 36, size.width, size.height - 10);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper old) => false;
}
