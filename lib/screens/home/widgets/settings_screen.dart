import 'dart:io';

import 'package:Finalyze/screens/home/widgets/security_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/screens/welcome_screen.dart';
import '../../../core/user_session.dart';
import '../../../widgets/app_back_button.dart';
import '../../../widgets/app_inner_bar.dart';
import '../../history/history_screen.dart';
import 'account_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isAnalysisEnabled = true;

  static const primaryBlue = Color(0xFF1A5694);

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (selected != null) {
      setState(() => _image = File(selected.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppInnerBar(title: "Settings", onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        child: Column(
          children: [
              const SizedBox(height: 20),
              _buildProfileHeader(),
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel("FRESHNESS INSIGHTS"),
                    _buildSwitchTile(),
                    const SizedBox(height: 12),

                    _buildNavTile(
                      icon: Icons.history_rounded,
                      title: "Scan History",
                      subtitle: "View your past fish analysis",
                      color: const Color(0xFF4EE3AA),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                HistoryScreen(userId: UserSession.userId ?? ''),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                    _sectionLabel("CONFIGURATION"),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildConfigTile(
                            icon: Icons.person_outline_rounded,
                            title: "Account Credentials",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AccountDetailsScreen(),
                                ),
                              );
                            },
                          ),
                          Divider(height: 1, color: Colors.grey.shade200),
                          _buildConfigTile(
                            icon: Icons.security_outlined,
                            title: "Security & Privacy",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SecurityScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                    _buildSignOutButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF4EE3AA), primaryBlue],
                ),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? Icon(
                        Icons.person_rounded,
                        size: 60,
                        color: Colors.grey.shade400,
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 5,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4EE3AA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          // Dynamically reads username from storage session context
          "Amna",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        Text(
          "User ID: ${UserSession.userId ?? 'Unknown'}",
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () async {
          await UserSession.clear();

          if (!mounted) return;

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthWrapper()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        label: const Text(
          "Sign Out",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFEBEB),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _iconBox(Icons.psychology_outlined, primaryBlue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enhanced Fish Analysis",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "AI-powered molecular detail",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAnalysisEnabled,
            activeColor: const Color(0xFF2CB88E),
            onChanged: (v) => setState(() => _isAnalysisEnabled = v),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            _iconBox(icon, color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryBlue),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
