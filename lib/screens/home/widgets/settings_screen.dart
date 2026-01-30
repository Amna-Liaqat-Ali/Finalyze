import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2B45),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Avatar Section
            _buildSettingsGroup([
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.cyanAccent.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Amna",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "amna.dev@example.com",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 25),

            _buildSectionTitle("Account"),
            _buildSettingsGroup([
              _buildSettingItem(
                Icons.person_outline,
                "Edit Profile",
                "Change your name & email",
              ),
              _buildSettingItem(
                Icons.history,
                "Scan History",
                "Manage your past analyses",
              ),
            ]),

            const SizedBox(height: 25),

            _buildSectionTitle("App Preferences"),
            _buildSettingsGroup([
              _buildSettingItem(
                Icons.high_quality,
                "High Accuracy Mode",
                "Uses more data for better results",
                trailing: Switch(
                  value: true,
                  onChanged: (v) {},
                  activeColor: Colors.cyanAccent,
                ),
              ),
              _buildSettingItem(
                Icons.notifications_active_outlined,
                "Push Notifications",
                "Alerts for new fish species",
              ),
            ]),

            const SizedBox(height: 25),

            _buildSectionTitle("Support"),
            _buildSettingsGroup([
              _buildSettingItem(
                Icons.help_outline,
                "Help Center",
                "FAQs and guides",
              ),
              _buildSettingItem(
                Icons.info_outline,
                "About Finalyze",
                "Version 1.0.2",
              ),
            ]),

            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "Log Out",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.3),
            size: 18,
          ),
      onTap: () {},
    );
  }
}
